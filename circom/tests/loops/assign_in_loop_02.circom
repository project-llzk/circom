// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Inner(i) {
    signal input in;
    signal output out;

    out <-- in & i;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    component c[n];
    for (var i = 0; i < n; i++) {
    	c[i] = Inner(i);
    	c[i].in <-- in;
    	out[i] <-- c[i].out;
    }
}

component main = Num2Bits(3);

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Num2Bits::@Num2Bits<[3]>>} {
// CHECK-NEXT:    poly.template @Inner {
// CHECK-NEXT:      poly.param @i
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Inner::@Inner<[@i]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner::@Inner<[@i]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Inner::@Inner<[@i]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[@i]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner::@Inner<[@i]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Inner::@Inner<[@i]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @c : !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_10]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_13_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_15]]) : (!array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_19]]) %[[VAL_13_IN]], %[[VAL_17]], %[[VAL_18]] : !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @i = %[[VAL_21]] }  : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_24]], @params = %[[VAL_23]] } (%[[VAL_22]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_13_LCV]]{{\[}}%[[VAL_26]]] = %[[VAL_25]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_27]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_28]][@in] = %[[VAL_8]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13_LCV]]{{\[}}%[[VAL_30]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_32]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:            pod.write %[[VAL_31]][@count] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:            scf.if %[[VAL_38]] {
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @Inner::@Inner::@compute(%[[VAL_40]]) {(%[[VAL_42]])} : (!felt.type<"bn128">) -> !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              pod.write %[[VAL_31]][@comp] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_13_LCV]]{{\[}}%[[VAL_44]]] = %[[VAL_31]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13_LCV]]{{\[}}%[[VAL_45]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@Inner::@Inner<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_13_LCV]], %[[VAL_20]], %[[VAL_51]] : !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@c$inputs] = %[[VAL_16]]#1 : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]] to %[[VAL_53]] step %[[VAL_55]] {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]#0{{\[}}%[[VAL_56]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_52]]{{\[}}%[[VAL_56]]] = %[[VAL_58]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@c] = %[[VAL_52]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@out] = %[[VAL_12]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_61]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@c] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@c$inputs] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_68]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_69]]) %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @i = %[[VAL_70]] }  : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_71]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_70]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_77]] to %[[VAL_76]] step %[[VAL_78]] {
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_79]]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_79]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_80]], %[[VAL_82]]) : (!struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
