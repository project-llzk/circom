// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

template A() {
    signal input a[2];
    signal input b[2];
    signal output c[4];
    signal x;

    for (var i = 0; i < 4; i++) {
        if (i % 2 == 0) {
            c[i] <== a[i \ 2];
        } else {
            c[i] <== b[i \ 2];
        }
    }

    x <== c[0];
}

component main {public [a, b]} = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @c : !array.type<4 x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.field @x : !felt.type
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type> {llzk.pub}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type> {llzk.pub}) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<4 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]])
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_11]], %[[VAL_12]])
// CHECK-NEXT:          scf.if %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_9]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_16]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_18]]] = %[[VAL_17]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_9]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]]
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_21]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_23]]] = %[[VAL_22]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_25]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]]
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_27]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@x] = %[[VAL_28]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@c] = %[[VAL_3]] : <@A<[]>>, !array.type<4 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type> {llzk.pub}, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type> {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<4 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!array.type<4 x !felt.type>, !felt.type) -> (!array.type<4 x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_36]], %[[VAL_37]])
// CHECK-NEXT:          scf.condition(%[[VAL_38]]) %[[VAL_35]], %[[VAL_36]] : !array.type<4 x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_40]], %[[VAL_41]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_42]], %[[VAL_43]])
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_44]] -> (!array.type<4 x !felt.type>) {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_40]], %[[VAL_46]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]]
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_48]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@c] : <@A<[]>>, !array.type<4 x !felt.type>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_51]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_52]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_50]] : !array.type<4 x !felt.type>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_40]], %[[VAL_53]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]]
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_55]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@c] : <@A<[]>>, !array.type<4 x !felt.type>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_58]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_59]], %[[VAL_56]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_57]] : !array.type<4 x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_60]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_45]], %[[VAL_61]] : !array.type<4 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]]
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]#0{{\[}}%[[VAL_63]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@x] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_65]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
