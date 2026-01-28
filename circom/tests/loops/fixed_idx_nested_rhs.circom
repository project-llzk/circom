// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
pragma circom 2.0.0;

template FixIdxNested() {
    signal input in[16];
    signal output out[16];
    
    var arr[16] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11];

    for (var i = 0; i < 16; i++) {
        out[i] <== in[arr[i]];
    }
}

component main = FixIdxNested();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @FixIdxNested<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<16 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<16 x !felt.type>) -> !struct.type<@FixIdxNested<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@FixIdxNested<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]] : <16 x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]], %[[VAL_15]], %[[VAL_16]], %[[VAL_17]], %[[VAL_18]], %[[VAL_19]], %[[VAL_20]] : <16 x !felt.type>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]])
// CHECK-NEXT:          scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_28]]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]]
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_30]]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_32]]] = %[[VAL_31]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_34]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_2]] : <@FixIdxNested<[]>>, !array.type<16 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@FixIdxNested<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !struct.type<@FixIdxNested<[]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<16 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16 x !felt.type>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]], %[[VAL_38]] : <16 x !felt.type>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_40]], %[[VAL_41]], %[[VAL_42]], %[[VAL_43]], %[[VAL_44]], %[[VAL_45]], %[[VAL_46]], %[[VAL_47]], %[[VAL_48]], %[[VAL_49]], %[[VAL_50]], %[[VAL_51]], %[[VAL_52]], %[[VAL_53]], %[[VAL_54]], %[[VAL_55]] : <16 x !felt.type>
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (!felt.type, !array.type<16 x !felt.type>) -> (!felt.type, !array.type<16 x !felt.type>) {
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_61]])
// CHECK-NEXT:          scf.condition(%[[VAL_62]]) %[[VAL_59]], %[[VAL_60]] : !felt.type, !array.type<16 x !felt.type>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_64:[0-9a-zA-Z_\.]+]]: !array.type<16 x !felt.type>):
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]]
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_65]]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]]
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_67]]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_35]][@out] : <@FixIdxNested<[]>>, !array.type<16 x !felt.type>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]]
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_70]]] : <16 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_71]], %[[VAL_68]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_72]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_73]], %[[VAL_69]] : !felt.type, !array.type<16 x !felt.type>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
