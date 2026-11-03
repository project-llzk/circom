// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Conditions using hidden input-tag parameters can select a compile-time layout.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Select() {
    Tagged() input left;
    Tagged() input right;
    Tagged() merged;
    if (left.x.size == 2) { merged <-- left; }
    else { merged <-- right; }
    Vec(merged.x.size) output out;
    for (var i = 0; i < merged.x.size; i++) { out.x[i] <== merged.x; }
}

template Main() {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    component selected = Select();
    selected.left <== left;
    selected.right <== right;
    signal output out;
    out <== selected.out.x[0];
}

component main = Main();

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @left : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @right : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @selected : !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:        struct.member @selected$inputs : !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = pod.new : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_1]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_1]][@x] = %[[VAL_4]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@x] = %[[VAL_6]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$left$x$size" = %[[VAL_8]], @"$tag$right$x$size" = %[[VAL_9]], @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" = %[[VAL_10]] }  : <[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@left] = %[[VAL_1]] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_17]], %[[VAL_18]], %[[VAL_16]] : index
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_21]] {
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_13]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_26]] {
// TEMPLATED-NEXT:              %[[VAL_27:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_28:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_29:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_30:[0-9a-zA-Z_.-]+]] = function.call @Select::@Select::@compute(%[[VAL_28]], %[[VAL_29]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_13]][@comp] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@right] = %[[VAL_2]] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_34]], %[[VAL_35]], %[[VAL_33]] : index
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_38]] {
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_39]], %[[VAL_40]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_13]][@count] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_43:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_41]], %[[VAL_42]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_43]] {
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_45:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_47:[0-9a-zA-Z_.-]+]] = function.call @Select::@Select::@compute(%[[VAL_45]], %[[VAL_46]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_13]][@comp] = %[[VAL_47]] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_48]][@out] : <@Select::@Select<[2, 3, 2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_49]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_52]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_53]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@selected$inputs] = %[[VAL_3]] : <@Main::@Main<[]>>, !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Select::@Select<[2, 3, 2]>>, @params: !pod.type<[@"$tag$left$x$size": !felt.type<"bn128">, @"$tag$right$x$size": !felt.type<"bn128">, @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)": !felt.type<"bn128">]>]>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@selected] = %[[VAL_54]] : <@Main::@Main<[]>>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@left] = %[[VAL_1]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@right] = %[[VAL_2]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_0]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_55:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_55]][@left] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_55]][@right] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_55]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_55]][@selected] : <@Main::@Main<[]>>, !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_55]][@selected$inputs] : <@Main::@Main<[]>>, !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_56]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_64]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_56]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_68]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_59]][@out] : <@Select::@Select<[2, 3, 2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_71]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_74]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_58]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Select::@Select::@constrain(%[[VAL_59]], %[[VAL_76]], %[[VAL_77]]) : (!struct.type<@Select::@Select<[2, 3, 2]>>, !pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Select {
// TEMPLATED-NEXT:      poly.param @"$tag$left$x$size"
// TEMPLATED-NEXT:      poly.param @"$tag$right$x$size"
// TEMPLATED-NEXT:      poly.param @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" : index
// TEMPLATED-NEXT:      struct.def @Select {
// TEMPLATED-NEXT:        struct.member @merged : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_78:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "left"}, %[[VAL_79:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "right"}) -> !struct.type<@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = struct.new : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" : index
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_81]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$left$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$right$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_83]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_87]] -> (!pod.type<[@x: !felt.type<"bn128">]>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_80]][@merged] = %[[VAL_78]] : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_78]] : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            struct.writem %[[VAL_80]][@merged] = %[[VAL_79]] : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_79]] : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_91:[0-9a-zA-Z_.-]+]] = %[[VAL_89]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_83]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_93]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              scf.yield %[[VAL_83]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              scf.yield %[[VAL_84]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_91]], %[[VAL_94]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_95]]) %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_96:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_88]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_85]][@x] : <[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_98]]{{\[}}%[[VAL_99]]] : <@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_98]]{{\[}}%[[VAL_99]]] = %[[VAL_97]] : <@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_85]][@x] = %[[VAL_98]] : <[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_96]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_102]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_80]][@out] = %[[VAL_85]] : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, !pod.type<[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_80]] : !struct.type<@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_103:[0-9a-zA-Z_.-]+]]: !struct.type<@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, %[[VAL_104:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "left"}, %[[VAL_105:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "right"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" : index
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_106]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$left$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$right$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_103]][@merged] : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_103]][@out] : <@Select::@Select<[@"$tag$left$x$size", @"$tag$right$x$size", @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)"]>>, !pod.type<[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_108]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_113]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_116:[0-9a-zA-Z_.-]+]] = %[[VAL_114]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_108]], %[[VAL_117]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_118]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              scf.yield %[[VAL_108]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              scf.yield %[[VAL_109]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_116]], %[[VAL_119]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_120]]) %[[VAL_116]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_121:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@x] : <[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_125:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_124]]] : <@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_125]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_127:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_121]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_127]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_1::@Main_1<[]>>} {
// CONCRETE-NEXT:    poly.template @Main_1 {
// CONCRETE-NEXT:      struct.def @Main_1 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @left : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @right : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @selected : !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:        struct.member @selected$inputs : !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_1::@Main_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = pod.new : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_1]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_1]][@x] = %[[VAL_7]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@x] = %[[VAL_9]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_6]][@left] = %[[VAL_1]] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_14]], %[[VAL_15]], %[[VAL_13]] : index
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_16]], %[[VAL_17]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_18]] {
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_23:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_23]] {
// CONCRETE-NEXT:              %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_25:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_26:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_27:[0-9a-zA-Z_.-]+]] = function.call @Select_0::@Select_0::@compute(%[[VAL_25]], %[[VAL_26]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_6]][@right] = %[[VAL_2]] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_30]] : index
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_31]], %[[VAL_32]], %[[VAL_30]] : index
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_34]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_35]] {
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_38:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_36]], %[[VAL_37]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_38]], %[[VAL_39]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_40]] {
// CONCRETE-NEXT:              %[[VAL_41:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_42:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_43:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_44:[0-9a-zA-Z_.-]+]] = function.call @Select_0::@Select_0::@compute(%[[VAL_42]], %[[VAL_43]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_45]][@out] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_49]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_50]] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@selected$inputs] = %[[VAL_6]] : <@Main_1::@Main_1<[]>>, !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Select_0::@Select_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@selected] = %[[VAL_51]] : <@Main_1::@Main_1<[]>>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@left] = %[[VAL_1]] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@right] = %[[VAL_2]] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_0]] : !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_52:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_1::@Main_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@out] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@left] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@right] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@selected] : <@Main_1::@Main_1<[]>>, !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@selected$inputs] : <@Main_1::@Main_1<[]>>, !pod.type<[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_54]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_59]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_55]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_62]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_54]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_63]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_55]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_56]][@out] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_68]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_71]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@left] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@right] : <[@left: !pod.type<[@x: !felt.type<"bn128">]>, @right: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Select_0::@Select_0::@constrain(%[[VAL_56]], %[[VAL_73]], %[[VAL_74]]) : (!struct.type<@Select_0::@Select_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Select_0 {
// CONCRETE-NEXT:      struct.def @Select_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @merged : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_75:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "left"}, %[[VAL_76:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "right"}) -> !struct.type<@Select_0::@Select_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = struct.new : <@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_77]][@merged] = %[[VAL_75]] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_81:[0-9a-zA-Z_.-]+]] = %[[VAL_79]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_81]], %[[VAL_82]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_83]]) %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_84:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_75]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_78]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_87:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_87]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_86]]{{\[}}%[[VAL_87]]] = %[[VAL_85]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_78]][@x] = %[[VAL_86]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_84]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_90]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_77]][@out] = %[[VAL_78]] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_77]] : !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_91:[0-9a-zA-Z_.-]+]]: !struct.type<@Select_0::@Select_0<[]>>, %[[VAL_92:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "left"}, %[[VAL_93:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "right"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_91]][@out] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_91]][@merged] : <@Select_0::@Select_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_98:[0-9a-zA-Z_.-]+]] = %[[VAL_96]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_98]], %[[VAL_99]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_100]]) %[[VAL_98]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_101:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_95]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_94]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_104]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_105]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_101]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_107]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }
