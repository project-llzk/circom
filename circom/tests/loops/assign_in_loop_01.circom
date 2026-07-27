// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Inner() {
    signal input in;
    signal output out;

    out <-- in & 1;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    component c[n];
    for (var i = 0; i < n; i++) {
    	c[i] = Inner();
    	c[i].in <-- in;
    	out[i] <-- c[i].out;
    }
}

component main = Num2Bits(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Num2Bits::@Num2Bits<[3]>>} {
// CHECK-NEXT:    poly.template @Inner {
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Inner::@Inner<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner::@Inner<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Inner::@Inner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner::@Inner<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Inner::@Inner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @c : !array.type<@n x !struct.type<@Inner::@Inner<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]] to %[[VAL_14]] step %[[VAL_16]] {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_17]]] = %[[VAL_19]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]], %[[VAL_24]] : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_32]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_33]][@in] = %[[VAL_7]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_26]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_35]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_37]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:            pod.write %[[VAL_36]][@count] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_41]], %[[VAL_42]] : index
// CHECK-NEXT:            scf.if %[[VAL_43]] {
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = function.call @Inner::@Inner::@compute(%[[VAL_45]]) : (!felt.type<"bn128">) -> !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:              pod.write %[[VAL_36]][@comp] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_12]]{{\[}}%[[VAL_47]]] = %[[VAL_36]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_48]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@out] : <@Inner::@Inner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_52]]] = %[[VAL_51]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_26]], %[[VAL_54]] : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_8]][@c$inputs] = %[[VAL_22]]#0 : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Inner::@Inner<[]>>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_57]] to %[[VAL_56]] step %[[VAL_58]] {
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_59]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_59]]] = %[[VAL_61]] : <@n x !struct.type<@Inner::@Inner<[]>>>, !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_8]][@c] = %[[VAL_55]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_8]][@out] = %[[VAL_11]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_64]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@c] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[]>>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@c$inputs] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_65]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_72]]) %[[VAL_71]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Inner::@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_73]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_79]] to %[[VAL_78]] step %[[VAL_80]] {
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_81]]] : <@n x !struct.type<@Inner::@Inner<[]>>>, !struct.type<@Inner::@Inner<[]>>
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_81]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_82]], %[[VAL_84]]) : (!struct.type<@Inner::@Inner<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
