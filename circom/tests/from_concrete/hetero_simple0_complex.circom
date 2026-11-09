// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// Simple case, same buses for all the elements in the heterogeneus array of components
// Choose n,m,l to make the array homogeneus or heterogeneus

template A(n) {
    signal output out;

    if (n % 2 == 0) {
        out <== 1;
    } else{
        out <== 2;
    }
}

template B(n) {
    signal output out[3];

    out[0] <== n;
    out[1] <== n*33;
    out[2] <== n*66;
}

template C() {
    component a_aux[3];
    component b_aux[3];

    a_aux[0] = A(1); // returns 2
    a_aux[1] = A(2); // returns 1
    a_aux[2] = A(3); // returns 2

    b_aux[0] = B(1); // returns [1, 33, 66]
    b_aux[1] = B(100); // returns [100, 3300, 6600]
    b_aux[2] = B(10000000); // returns [10000000, 330000000, 660000000]

    signal output out[3];

    out[0] <-- b_aux[0].out[a_aux[0].out - a_aux[a_aux[2].out].out]; // should be b_aux[0].out[0] = 1
    out[1] <-- b_aux[a_aux[1].out].out[a_aux[1].out]; // should be b_aux[1].out[1] = 3300
    out[2] <-- b_aux[2].out[a_aux[2].out]; // should be b_aux[2].out[2] = 660000000

    // OUTPUT THAT WE OBTAIN: [2, 2, 33]
    // ERROR -> OVERWRITING LOCALS

}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@C_6::@C_6<[]>>} {
// CHECK-NEXT:    poly.template @A_0 {
// CHECK-NEXT:      struct.def @A_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_3]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_1 {
// CHECK-NEXT:      struct.def @A_1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_5]][@out] = %[[VAL_6]] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_5]] : !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_7]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_2 {
// CHECK-NEXT:      struct.def @A_2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@out] = %[[VAL_11]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_3 {
// CHECK-NEXT:      struct.def @B_3 {
// CHECK-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_3::@B_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.new : <@B_3::@B_3<[]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  66 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_25]]] = %[[VAL_23]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_15]][@out] = %[[VAL_16]] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_15]] : !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@B_3::@B_3<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_30]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_31]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_34]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_35]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  66 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_38]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_4 {
// CHECK-NEXT:      struct.def @B_4 {
// CHECK-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_4::@B_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@B_4::@B_4<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  100 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_41]]{{\[}}%[[VAL_44]]] = %[[VAL_42]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  3300 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_41]]{{\[}}%[[VAL_47]]] = %[[VAL_45]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  6600 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_41]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_40]][@out] = %[[VAL_41]] : <@B_4::@B_4<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@B_4::@B_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !struct.type<@B_4::@B_4<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@out] : <@B_4::@B_4<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  100 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_55]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  3300 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_59]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_60]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  6600 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_63]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_64]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_5 {
// CHECK-NEXT:      struct.def @B_5 {
// CHECK-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_5::@B_5<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.new : <@B_5::@B_5<[]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  10000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_66]]{{\[}}%[[VAL_69]]] = %[[VAL_67]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  330000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_66]]{{\[}}%[[VAL_72]]] = %[[VAL_70]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  660000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_66]]{{\[}}%[[VAL_75]]] = %[[VAL_73]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_65]][@out] = %[[VAL_66]] : <@B_5::@B_5<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_65]] : !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !struct.type<@B_5::@B_5<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@B_5::@B_5<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  10000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_80]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_81]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  330000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_84]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_85]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  660000000 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_88]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C_6 {
// CHECK-NEXT:      struct.def @C_6 {
// CHECK-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a_aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CHECK-NEXT:        struct.member @a_aux$inputs : !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:        struct.member @b_aux : !pod.type<[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>
// CHECK-NEXT:        struct.member @b_aux$inputs : !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@C_6::@C_6<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.new : <@C_6::@C_6<[]>>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute() : () -> !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_92]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute() : () -> !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_94]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute() : () -> !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_96]] }  : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_93]], @idx_1 = %[[VAL_95]], @idx_2 = %[[VAL_97]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = function.call @B_3::@B_3::@compute() : () -> !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_100]] }  : <[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = function.call @B_4::@B_4::@compute() : () -> !struct.type<@B_4::@B_4<[]>>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_102]] }  : <[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = function.call @B_5::@B_5::@compute() : () -> !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_104]] }  : <[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_101]], @idx_1 = %[[VAL_103]], @idx_2 = %[[VAL_105]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@out] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_112]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_116]] : index
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_115]], %[[VAL_117]] : i1, i1
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_119]] : index
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_115]], %[[VAL_120]] : i1, i1
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_122]] : index
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_115]], %[[VAL_123]] : i1, i1
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_124]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_128]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_121]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_118]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:                  %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@out] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_138:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@comp] : <[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_140]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_110]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_143]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_91]]{{\[}}%[[VAL_146]]] = %[[VAL_144]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_148]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_151]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_153]], %[[VAL_155]] : index
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_154]], %[[VAL_156]] : i1, i1
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_153]], %[[VAL_158]] : index
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_154]], %[[VAL_159]] : i1, i1
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_153]], %[[VAL_161]] : index
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_154]], %[[VAL_162]] : i1, i1
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_163]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@comp] : <[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_167]][@out] : <@B_5::@B_5<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_169]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_160]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@comp] : <[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_4::@B_4<[]>>
// CHECK-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_173]][@out] : <@B_4::@B_4<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_174]]{{\[}}%[[VAL_175]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_157]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@comp] : <[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_179]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_181]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_182]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_171]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_91]]{{\[}}%[[VAL_185]]] = %[[VAL_164]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_187]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@comp] : <[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_190]][@out] : <@B_5::@B_5<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_191]]{{\[}}%[[VAL_192]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_91]]{{\[}}%[[VAL_195]]] = %[[VAL_193]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_90]][@a_aux$inputs] = %[[VAL_99]] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_197]], @idx_1 = %[[VAL_199]], @idx_2 = %[[VAL_201]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_90]][@a_aux] = %[[VAL_202]] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_90]][@b_aux$inputs] = %[[VAL_107]] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@comp] : <[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@comp] : <[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_4::@B_4<[]>>
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_3::@B_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_4::@B_4<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_207]][@comp] : <[@count: index, @comp: !struct.type<@B_5::@B_5<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_204]], @idx_1 = %[[VAL_206]], @idx_2 = %[[VAL_208]] }  : <[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_90]][@b_aux] = %[[VAL_209]] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_90]][@out] = %[[VAL_91]] : <@C_6::@C_6<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_90]] : !struct.type<@C_6::@C_6<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_210:[0-9a-zA-Z_\.]+]]: !struct.type<@C_6::@C_6<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@out] : <@C_6::@C_6<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@a_aux] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@a_aux$inputs] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@b_aux] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@b_aux$inputs] : <@C_6::@C_6<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@out] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_218]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_222]] : index
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_221]], %[[VAL_223]] : i1, i1
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_225]] : index
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_221]], %[[VAL_226]] : i1, i1
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_228]] : index
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_221]], %[[VAL_229]] : i1, i1
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_230]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_233]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_227]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:                %[[VAL_237:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_236]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_238:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_224]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:                  %[[VAL_240:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_239]][@out] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_241:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_238]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_242]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_244]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_246]][@out] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@idx_0] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_248]]) : (!struct.type<@A_0::@A_0<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@idx_1] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_250]]) : (!struct.type<@A_1::@A_1<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@idx_2] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_252]]) : (!struct.type<@A_2::@A_2<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@idx_0] : <[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>, !struct.type<@B_3::@B_3<[]>>
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@idx_0] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @B_3::@B_3::@constrain(%[[VAL_254]]) : (!struct.type<@B_3::@B_3<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@idx_1] : <[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>, !struct.type<@B_4::@B_4<[]>>
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@idx_1] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @B_4::@B_4::@constrain(%[[VAL_256]]) : (!struct.type<@B_4::@B_4<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@idx_2] : <[@idx_0: !struct.type<@B_3::@B_3<[]>>, @idx_1: !struct.type<@B_4::@B_4<[]>>, @idx_2: !struct.type<@B_5::@B_5<[]>>]>, !struct.type<@B_5::@B_5<[]>>
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@idx_2] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>, @idx_2: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @B_5::@B_5::@constrain(%[[VAL_258]]) : (!struct.type<@B_5::@B_5<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
