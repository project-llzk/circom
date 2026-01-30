// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Vector copy version of `array_copy3_vec.circom` test.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    for(var i = 0; i < n; i++) {
        for(var j = 0; j < n; j++) {
            out[i][j] <== inp[i][j];
        }
    }
}

component main = Array3(5);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Array3<[5]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array3<[@n]> {
// CHECK-NEXT:      struct.field @out : !array.type<@n,@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) -> !struct.type<@Array3<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array3<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_11]], %[[VAL_2]])
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_11]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_14]], %[[VAL_15]]] : <@n,@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_17]], %[[VAL_18]]] = %[[VAL_16]] : <@n,@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_20]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_22]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Array3<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@Array3<[@n]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_23]][@out] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_29]], %[[VAL_25]])
// CHECK-NEXT:          scf.condition(%[[VAL_30]]) %[[VAL_29]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_25]])
// CHECK-NEXT:            scf.condition(%[[VAL_35]]) %[[VAL_34]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]]
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]]
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_37]], %[[VAL_38]]] : <@n,@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]]
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]]
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_40]], %[[VAL_41]]] : <@n,@n x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_42]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_43]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_44]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_46]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
