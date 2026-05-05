// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function arr() {
   var x[1][2][3] = [[[2,3,4], [5,6,7]]];
   var y[1][1][1] = x;
   return y;
}

template ArrayShenanigans() {
   var z[2][2][2] = arr();
   signal output outp[2][2][2] <== z;
}

component main = ArrayShenanigans();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>} {
// CHECK-NEXT:    poly.template @arr {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @arr() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_0]], %[[VAL_0]], %[[VAL_0]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_3]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_4]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_5]]{{\[}}%[[VAL_6]]] = %[[VAL_2]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_7]], %[[VAL_8]], %[[VAL_9]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_11]], %[[VAL_12]], %[[VAL_13]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_16]]] = %[[VAL_10]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_17]]] = %[[VAL_14]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.new  : <1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_18]]{{\[}}%[[VAL_19]]] = %[[VAL_15]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_20]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new  : <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_22]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.new  : <1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_24]]{{\[}}%[[VAL_25]]] = %[[VAL_22]] : <1,1,1 x !felt.type<"bn128">>, <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_26]], %[[VAL_27]] : index
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_28]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_26]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_27]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_30]], %[[VAL_31]] : index
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_32]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_30]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_31]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_36]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_34]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_35]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]] to %[[VAL_29]] step %[[VAL_39]] {
// CHECK-NEXT:          scf.for %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_38]] to %[[VAL_33]] step %[[VAL_39]] {
// CHECK-NEXT:            scf.for %[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_38]] to %[[VAL_37]] step %[[VAL_39]] {
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_40]], %[[VAL_41]], %[[VAL_42]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_24]]{{\[}}%[[VAL_40]], %[[VAL_41]], %[[VAL_42]]] = %[[VAL_43]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_24]] : (!array.type<1,1,1 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_44]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayShenanigans {
// CHECK-NEXT:      struct.def @ArrayShenanigans {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_46]], %[[VAL_46]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_48]]{{\[}}%[[VAL_49]]] = %[[VAL_47]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_48]]{{\[}}%[[VAL_50]]] = %[[VAL_47]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.new  : <2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_51]]{{\[}}%[[VAL_52]]] = %[[VAL_48]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_51]]{{\[}}%[[VAL_53]]] = %[[VAL_48]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_45]][@outp] = %[[VAL_54]] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_45]] : !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@outp] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_57]], %[[VAL_57]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_59]]{{\[}}%[[VAL_60]]] = %[[VAL_58]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_59]]{{\[}}%[[VAL_61]]] = %[[VAL_58]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.new  : <2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_62]]{{\[}}%[[VAL_63]]] = %[[VAL_59]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_62]]{{\[}}%[[VAL_64]]] = %[[VAL_59]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_65]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
