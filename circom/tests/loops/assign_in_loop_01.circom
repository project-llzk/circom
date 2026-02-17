// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Num2Bits<[3]>>} {
// CHECK-NEXT:    struct.def @Inner<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Inner<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Inner<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Inner<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Inner<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Num2Bits<[@n]> {
// CHECK-NEXT:      struct.member @out : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.member @c : !array.type<@n x !struct.type<@Inner<[]>>>
// CHECK-NEXT:      struct.member @c$inputs : !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits<[@n]>>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_12]] step %[[VAL_14]] {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_15]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          pod.write %[[VAL_16]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_15]]] = %[[VAL_16]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@n x !pod.type<[@in: !felt.type]>>, !felt.type) -> (!array.type<@n x !pod.type<[@in: !felt.type]>>, !felt.type) {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_9]])
// CHECK-NEXT:          scf.condition(%[[VAL_23]]) %[[VAL_21]], %[[VAL_22]] : !array.type<@n x !pod.type<[@in: !felt.type]>>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type]>>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]] }  : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_28]]] = %[[VAL_27]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_29]]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          pod.write %[[VAL_30]][@in] = %[[VAL_7]] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_32]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@count] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:          pod.write %[[VAL_33]][@count] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:          scf.if %[[VAL_38]] {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = function.call @Inner::@compute(%[[VAL_39]]) : (!felt.type) -> !struct.type<@Inner<[]>>
// CHECK-NEXT:            pod.write %[[VAL_33]][@comp] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner<[]>>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_41]]] = %[[VAL_33]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_42]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner<[]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out] : <@Inner<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_46]]] = %[[VAL_45]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]], %[[VAL_48]] : !array.type<@n x !pod.type<[@in: !felt.type]>>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_8]][@c$inputs] = %[[VAL_20]]#0 : <@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Inner<[]>>>
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_51]] to %[[VAL_50]] step %[[VAL_52]] {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_53]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@comp] : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner<[]>>
// CHECK-NEXT:          array.write %[[VAL_49]]{{\[}}%[[VAL_53]]] = %[[VAL_55]] : <@n x !struct.type<@Inner<[]>>>, !struct.type<@Inner<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_8]][@c] = %[[VAL_49]] : <@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner<[]>>>
// CHECK-NEXT:        struct.writem %[[VAL_8]][@out] = %[[VAL_10]] : <@Num2Bits<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_8]] : !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits<[@n]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@Num2Bits<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@c] : <@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner<[]>>>
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@c$inputs] : <@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_62]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_64]], %[[VAL_58]])
// CHECK-NEXT:          scf.condition(%[[VAL_65]]) %[[VAL_64]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_67]] }  : <[@count: index, @comp: !struct.type<@Inner<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_69]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_70]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_72]] to %[[VAL_71]] step %[[VAL_73]] {
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_60]]{{\[}}%[[VAL_74]]] : <@n x !struct.type<@Inner<[]>>>, !struct.type<@Inner<[]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_74]]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @Inner::@constrain(%[[VAL_75]], %[[VAL_77]]) : (!struct.type<@Inner<[]>>, !felt.type) -> ()
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
