// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayShenanigans() {
   var x[2][2];
   var y[1][3] = [[9,8,7]];
   x = y;
   signal output outp[2][2] <== x;
}

component main = ArrayShenanigans();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArrayShenanigans<[]>>} {
// CHECK-NEXT:    struct.def @ArrayShenanigans<[]> {
// CHECK-NEXT:      struct.member @outp : !array.type<2,2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ArrayShenanigans<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]], %[[VAL_6]] : <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_8]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <1,3 x !felt.type>, <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_10]], %[[VAL_11]], %[[VAL_12]] : <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_14]]{{\[}}%[[VAL_15]]] = %[[VAL_13]] : <1,3 x !felt.type>, <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_14]], %[[VAL_16]] : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_14]], %[[VAL_18]] : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]] to %[[VAL_20]] step %[[VAL_23]] {
// CHECK-NEXT:          scf.for %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]] to %[[VAL_21]] step %[[VAL_23]] {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_24]], %[[VAL_17]] : index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_25]], %[[VAL_19]] : index
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_26]], %[[VAL_27]] : i1, i1
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_28]] -> (!felt.type) {
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_24]], %[[VAL_25]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_30]] : !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              scf.yield %[[VAL_31]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_24]], %[[VAL_25]]] = %[[VAL_29]] : <2,2 x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_0]][@outp] = %[[VAL_3]] : <@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@ArrayShenanigans<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@outp] : <@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_34]], %[[VAL_34]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_36]]{{\[}}%[[VAL_37]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_36]]{{\[}}%[[VAL_38]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_39]], %[[VAL_39]], %[[VAL_39]] : <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_41]]{{\[}}%[[VAL_42]]] = %[[VAL_40]] : <1,3 x !felt.type>, <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_43]], %[[VAL_44]], %[[VAL_45]] : <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_47]]{{\[}}%[[VAL_48]]] = %[[VAL_46]] : <1,3 x !felt.type>, <3 x !felt.type>
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_47]], %[[VAL_49]] : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_47]], %[[VAL_51]] : <1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_55]] to %[[VAL_53]] step %[[VAL_56]] {
// CHECK-NEXT:          scf.for %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_55]] to %[[VAL_54]] step %[[VAL_56]] {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_57]], %[[VAL_50]] : index
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_58]], %[[VAL_52]] : index
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_59]], %[[VAL_60]] : i1, i1
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_61]] -> (!felt.type) {
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_57]], %[[VAL_58]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_63]] : !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              scf.yield %[[VAL_64]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            array.write %[[VAL_36]]{{\[}}%[[VAL_57]], %[[VAL_58]]] = %[[VAL_62]] : <2,2 x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_33]], %[[VAL_36]] : !array.type<2,2 x !felt.type>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
