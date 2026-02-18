// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal output out;
    signal temp <-- -in;
    out <-- temp * temp;
}

template SubCmps0C(n) {
    signal input ins[n];
    signal output outs[n];

    component zeros[n];
    for (var i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <-- ins[i];
        outs[i] <-- zeros[i].out;
    }
}

component main = SubCmps0C(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps0C<[2]>>} {
// CHECK-NEXT:    struct.def @IsZero<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @temp : !felt.type
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@IsZero<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@IsZero<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@temp] = %[[VAL_2]] : <@IsZero<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_2]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@IsZero<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@IsZero<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@IsZero<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@IsZero<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@temp] : <@IsZero<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @SubCmps0C<[@n]> {
// CHECK-NEXT:      struct.member @outs : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.member @zeros : !array.type<@n x !struct.type<@IsZero<[]>>>
// CHECK-NEXT:      struct.member @zeros$inputs : !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@SubCmps0C<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0C<[@n]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]] to %[[VAL_13]] step %[[VAL_15]] {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_16]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          pod.write %[[VAL_17]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_16]]] = %[[VAL_17]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!felt.type, !array.type<@n x !pod.type<[@in: !felt.type]>>) -> (!felt.type, !array.type<@n x !pod.type<[@in: !felt.type]>>) {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_10]])
// CHECK-NEXT:          scf.condition(%[[VAL_24]]) %[[VAL_22]], %[[VAL_23]] : !felt.type, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type]>>):
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_30]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_32]]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          pod.write %[[VAL_33]][@in] = %[[VAL_31]] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_26]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_35]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@count] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:          pod.write %[[VAL_36]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:          scf.if %[[VAL_41]] {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @IsZero::@compute(%[[VAL_42]]) : (!felt.type) -> !struct.type<@IsZero<[]>>
// CHECK-NEXT:            pod.write %[[VAL_36]][@comp] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_44]]] = %[[VAL_36]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_45]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@comp] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@IsZero<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_50]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_51]], %[[VAL_26]] : !felt.type, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_9]][@zeros$inputs] = %[[VAL_21]]#1 : <@SubCmps0C<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@IsZero<[]>>>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]] to %[[VAL_53]] step %[[VAL_55]] {
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_56]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@comp] : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero<[]>>
// CHECK-NEXT:          array.write %[[VAL_52]]{{\[}}%[[VAL_56]]] = %[[VAL_58]] : <@n x !struct.type<@IsZero<[]>>>, !struct.type<@IsZero<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_9]][@zeros] = %[[VAL_52]] : <@SubCmps0C<[@n]>>, !array.type<@n x !struct.type<@IsZero<[]>>>
// CHECK-NEXT:        struct.writem %[[VAL_9]][@outs] = %[[VAL_11]] : <@SubCmps0C<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_9]] : !struct.type<@SubCmps0C<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0C<[@n]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@outs] : <@SubCmps0C<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@zeros] : <@SubCmps0C<[@n]>>, !array.type<@n x !struct.type<@IsZero<[]>>>
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@zeros$inputs] : <@SubCmps0C<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type]>>
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_67]], %[[VAL_61]])
// CHECK-NEXT:          scf.condition(%[[VAL_68]]) %[[VAL_67]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_70]] }  : <[@count: index, @comp: !struct.type<@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_72]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_73]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_75]] to %[[VAL_74]] step %[[VAL_76]] {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_77]]] : <@n x !struct.type<@IsZero<[]>>>, !struct.type<@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_77]]] : <@n x !pod.type<[@in: !felt.type]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @IsZero::@constrain(%[[VAL_78]], %[[VAL_80]]) : (!struct.type<@IsZero<[]>>, !felt.type) -> ()
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
