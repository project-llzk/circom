// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Like SubCmps1 but simpler (no constraints and fewer operations)
template IsZero() {
    signal input in;
    signal output out;
    out <-- -in;
}

template SubCmps0A(n) {
    signal input ins[n];
    signal output outs[n];

    component zeros[n];
    for (var i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <-- ins[i];
        outs[i] <-- zeros[i].out;
    }
}

component main = SubCmps0A(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps0A::@SubCmps0A<[2]>>} {
// CHECK-NEXT:    poly.template @IsZero {
// CHECK-NEXT:      struct.def @IsZero {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@IsZero::@IsZero<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmps0A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @SubCmps0A {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @zeros : !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:        struct.member @zeros$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@SubCmps0A::@SubCmps0A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0A::@SubCmps0A<[@n]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]] to %[[VAL_11]] step %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_14]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            pod.write %[[VAL_15]][@count] = %[[VAL_16]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_14]]] = %[[VAL_15]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_27]]] = %[[VAL_26]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_28]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_30]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_31]][@in] = %[[VAL_29]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_32]]] = %[[VAL_31]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_33]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:            pod.write %[[VAL_34]][@count] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:            scf.if %[[VAL_39]] {
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = function.call @IsZero::@IsZero::@compute(%[[VAL_40]]) : (!felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              pod.write %[[VAL_34]][@comp] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_10]]{{\[}}%[[VAL_42]]] = %[[VAL_34]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_43]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_47]]] = %[[VAL_46]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_49]], %[[VAL_24]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros$inputs] = %[[VAL_19]]#1 : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_54]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            array.write %[[VAL_50]]{{\[}}%[[VAL_54]]] = %[[VAL_56]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros] = %[[VAL_50]] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_7]][@outs] = %[[VAL_9]] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@SubCmps0A::@SubCmps0A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0A::@SubCmps0A<[@n]>>, %[[VAL_58:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@outs] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@zeros] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@zeros$inputs] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_65]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_66]]) %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_68]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_67]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_71]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_73]] to %[[VAL_72]] step %[[VAL_74]] {
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_75]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_75]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @IsZero::@IsZero::@constrain(%[[VAL_76]], %[[VAL_78]]) : (!struct.type<@IsZero::@IsZero<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
