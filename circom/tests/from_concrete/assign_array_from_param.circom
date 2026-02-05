// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Template(m) {
    signal output ret[2][2] <== m;
}

component main = Template([[0, 1], [2, 3]]);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Template_0<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Template_0<[]> {
// CHECK-NEXT:      struct.field @ret : !array.type<2,2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Template_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Template_0<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_2]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_7]]{{\[}}%[[VAL_8]]] = %[[VAL_3]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_7]]{{\[}}%[[VAL_9]]] = %[[VAL_6]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        struct.writef %[[VAL_0]][@ret] = %[[VAL_7]] : <@Template_0<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Template_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@Template_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_10]][@ret] : <@Template_0<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_11]], %[[VAL_12]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_14]], %[[VAL_15]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_17]]{{\[}}%[[VAL_18]]] = %[[VAL_13]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_17]]{{\[}}%[[VAL_19]]] = %[[VAL_16]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        constrain.eq %[[VAL_20]], %[[VAL_17]] : !array.type<2,2 x !felt.type>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
