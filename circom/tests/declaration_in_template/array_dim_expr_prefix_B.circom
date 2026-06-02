// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  var s = -6;
  signal input in[-s];
  s = -12;
  var x[-s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.expr @"Sub_s@281" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"Sub_s@305" {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !array.type<@"Sub_s@281" x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@281" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@305" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <@"Sub_s@305" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_11]], %[[VAL_12]] : <@"Sub_s@305" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]] to %[[VAL_13]] step %[[VAL_15]] {
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_16]]] = %[[VAL_10]] : <@"Sub_s@305" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@281" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@305" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_18]], %[[VAL_20]] : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_21]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_18]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_20]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]] to %[[VAL_22]] step %[[VAL_24]] {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_25]]] : <@"Sub_s@281" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_25]]] = %[[VAL_26]] : <@"Sub_s@305" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<@"Sub_s@281" x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@281" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@305" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <@"Sub_s@305" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_36]], %[[VAL_37]] : <@"Sub_s@305" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]] to %[[VAL_38]] step %[[VAL_40]] {
// CHECK-NEXT:            array.write %[[VAL_36]]{{\[}}%[[VAL_41]]] = %[[VAL_35]] : <@"Sub_s@305" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@281" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@305" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_43]], %[[VAL_45]] : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_46]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_43]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_45]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_48]] to %[[VAL_47]] step %[[VAL_49]] {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_50]]] : <@"Sub_s@281" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_36]]{{\[}}%[[VAL_50]]] = %[[VAL_51]] : <@"Sub_s@305" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
