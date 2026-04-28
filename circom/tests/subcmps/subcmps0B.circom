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

template SubCmps0B(n) {
    signal input ins[n];
    signal output outs[n];
    var temp;
    component zeros[n];
    for (var i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <-- ins[i];
        outs[i] <-- zeros[i].out;
        temp = zeros[i].out;
    }
}

component main = SubCmps0B(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps0B::@SubCmps0B<[2]>>} {
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
// CHECK-NEXT:    poly.template @SubCmps0B {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @SubCmps0B {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @zeros : !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:        struct.member @zeros$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@SubCmps0B::@SubCmps0B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0B::@SubCmps0B<[@n]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_18]]) %[[VAL_15]], %[[VAL_16]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_25]]] = %[[VAL_24]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_26]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_28]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_29]][@in] = %[[VAL_27]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_21]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_31]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:            pod.write %[[VAL_32]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:            scf.if %[[VAL_37]] {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@params] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = function.call @IsZero::@IsZero::@compute(%[[VAL_39]]) : (!felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              pod.write %[[VAL_32]][@comp] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_10]]{{\[}}%[[VAL_41]]] = %[[VAL_32]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_42]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_46]]] = %[[VAL_45]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_47]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_52]], %[[VAL_50]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros$inputs] = %[[VAL_14]]#2 : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_55]] to %[[VAL_54]] step %[[VAL_56]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_57]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_57]]] = %[[VAL_59]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros] = %[[VAL_53]] : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_7]][@outs] = %[[VAL_9]] : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@SubCmps0B::@SubCmps0B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0B::@SubCmps0B<[@n]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@outs] : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@zeros] : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@zeros$inputs] : <@SubCmps0B::@SubCmps0B<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_67]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_69]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_71]]) %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_73:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_76]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_80]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]] to %[[VAL_81]] step %[[VAL_83]] {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_84]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_84]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @IsZero::@IsZero::@constrain(%[[VAL_85]], %[[VAL_87]]) : (!struct.type<@IsZero::@IsZero<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
