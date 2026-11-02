// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.1.6;

bus A(){
    signal {a} x;
}

template error(){
    input A() x;
    input signal b;
    if(x.x.a > 0){
        x.x === b;
        log("adds constraint");
    }
}

template B(){
    input signal b;
    A() aux;
    aux.x.a = 0;
    aux.x <== 9;
    error()(aux, b);

    A() aux1;
    aux1.x.a = aux.x.a + 4;
    aux1.x <== b;
    error()(aux1, b);
}

component main = B();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_2::@B_2<[]>>} {
// CONCRETE-NEXT:    poly.template @B_2 {
// CONCRETE-NEXT:      struct.def @B_2 {
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @aux1 : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @error_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:        struct.member @error_[[MEMBER0]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @error_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:        struct.member @error_[[MEMBER1]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@x] = %[[VAL_12]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@b] = %[[VAL_0]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_17]], %[[VAL_18]], %[[VAL_16]] : index
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_21]] {
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_26]] {
// CONCRETE-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @error_0::@error_0::@compute(%[[VAL_28]], %[[VAL_29]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@x] = %[[VAL_2]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_34]], %[[VAL_35]], %[[VAL_33]] : index
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_38]] {
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_39]], %[[VAL_40]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_41]], %[[VAL_42]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_43]] {
// CONCRETE-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = function.call @error_0::@error_0::@compute(%[[VAL_45]], %[[VAL_46]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_47]] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_3]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_11]][@b] = %[[VAL_0]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_52]], %[[VAL_53]], %[[VAL_51]] : index
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_54]], %[[VAL_55]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_56]] {
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_10]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_61]] {
// CONCRETE-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @error_1::@error_1::@compute(%[[VAL_63]], %[[VAL_64]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_10]][@comp] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_11]][@x] = %[[VAL_3]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_67]], %[[VAL_68]] : index
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_69]], %[[VAL_70]], %[[VAL_68]] : index
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_71]], %[[VAL_72]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_73]] {
// CONCRETE-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_74]], %[[VAL_75]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_10]][@count] = %[[VAL_76]] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_76]], %[[VAL_77]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_78]] {
// CONCRETE-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = function.call @error_1::@error_1::@compute(%[[VAL_80]], %[[VAL_81]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_10]][@comp] = %[[VAL_82]] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@B_2::@B_2<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@error_0::@error_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER0]]] = %[[VAL_83]] : <@B_2::@B_2<[]>>, !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER1]]$inputs] = %[[VAL_11]] : <@B_2::@B_2<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@error_1::@error_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER1]]] = %[[VAL_84]] : <@B_2::@B_2<[]>>, !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@B_2::@B_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@B_2::@B_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@aux] : <@B_2::@B_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@aux1] : <@B_2::@B_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@error_[[MEMBER0]]] : <@B_2::@B_2<[]>>, !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@error_[[MEMBER0]]$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@error_[[MEMBER1]]] : <@B_2::@B_2<[]>>, !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@error_[[MEMBER1]]$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_95]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_100]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_102]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @error_0::@error_0::@constrain(%[[VAL_89]], %[[VAL_104]], %[[VAL_105]]) : (!struct.type<@error_0::@error_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @error_1::@error_1::@constrain(%[[VAL_91]], %[[VAL_106]], %[[VAL_107]]) : (!struct.type<@error_1::@error_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @error_0 {
// CONCRETE-NEXT:      struct.def @error_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_109:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@error_0::@error_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.new : <@error_0::@error_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_110]] : !struct.type<@error_0::@error_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !struct.type<@error_0::@error_0<[]>>, %[[VAL_112:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @error_1 {
// CONCRETE-NEXT:      struct.def @error_1 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_115:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@error_1::@error_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.new : <@error_1::@error_1<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_116]] : !struct.type<@error_1::@error_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_117:[0-9a-zA-Z_\.]+]]: !struct.type<@error_1::@error_1<[]>>, %[[VAL_118:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_119:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_120]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[]>>} {
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @aux : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @aux1 : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @error_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:        struct.member @error_[[MEMBER0]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @error_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:        struct.member @error_[[MEMBER1]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@x] = %[[VAL_6]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$x$x$a" = %[[VAL_8]] }  : <[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]], @params = %[[VAL_9]] }  : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@b] = %[[VAL_0]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_15]], %[[VAL_16]], %[[VAL_14]] : index
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_19]] {
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_20]], %[[VAL_21]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_11]][@count] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_24]] {
// TEMPLATED-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @error::@error::@compute(%[[VAL_26]], %[[VAL_27]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_11]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@x] = %[[VAL_2]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_30]], %[[VAL_31]] : index
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_32]], %[[VAL_33]], %[[VAL_31]] : index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_34]], %[[VAL_35]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_36]] {
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_11]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_41]] {
// TEMPLATED-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @error::@error::@compute(%[[VAL_43]], %[[VAL_44]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_11]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$x$x$a" = %[[VAL_47]] }  : <[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_49]], @params = %[[VAL_48]] }  : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_5]][@b] = %[[VAL_0]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_54]], %[[VAL_55]], %[[VAL_53]] : index
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_58]] {
// TEMPLATED-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_59]], %[[VAL_60]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_50]][@count] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_61]], %[[VAL_62]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_63]] {
// TEMPLATED-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@params] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @error::@error::@compute(%[[VAL_65]], %[[VAL_66]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_50]][@comp] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_5]][@x] = %[[VAL_3]] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_71]], %[[VAL_72]], %[[VAL_70]] : index
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_75]] {
// TEMPLATED-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@count] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_76]], %[[VAL_77]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_50]][@count] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_78]], %[[VAL_79]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_80]] {
// TEMPLATED-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@params] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = function.call @error::@error::@compute(%[[VAL_82]], %[[VAL_83]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_50]][@comp] = %[[VAL_84]] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@B::@B<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@error::@error<[0]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER0]]] = %[[VAL_85]] : <@B::@B<[]>>, !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER1]]$inputs] = %[[VAL_5]] : <@B::@B<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@comp] : <[@count: index, @comp: !struct.type<@error::@error<[4]>>, @params: !pod.type<[@"$tag$x$x$a": !felt.type<"bn128">]>]>, !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@error_[[MEMBER1]]] = %[[VAL_86]] : <@B::@B<[]>>, !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@aux] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@aux1] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@error_[[MEMBER0]]] : <@B::@B<[]>>, !struct.type<@error::@error<[0]>>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@error_[[MEMBER0]]$inputs] : <@B::@B<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@error_[[MEMBER1]]] : <@B::@B<[]>>, !struct.type<@error::@error<[4]>>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@error_[[MEMBER1]]$inputs] : <@B::@B<[]>>, !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_96]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_97]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_101]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_102]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_104]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @error::@error::@constrain(%[[VAL_91]], %[[VAL_106]], %[[VAL_107]]) : (!struct.type<@error::@error<[0]>>, !pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@x] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@b] : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @error::@error::@constrain(%[[VAL_93]], %[[VAL_108]], %[[VAL_109]]) : (!struct.type<@error::@error<[4]>>, !pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @error {
// TEMPLATED-NEXT:      poly.param @"$tag$x$x$a"
// TEMPLATED-NEXT:      struct.def @error {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_110:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@error::@error<[@"$tag$x$x$a"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.new : <@error::@error<[@"$tag$x$x$a"]>>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$x$x$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_113]], %[[VAL_114]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_115]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return %[[VAL_112]] : !struct.type<@error::@error<[@"$tag$x$x$a"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !struct.type<@error::@error<[@"$tag$x$x$a"]>>, %[[VAL_117:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "x"}, %[[VAL_118:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$x$x$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_119]], %[[VAL_120]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_121]] {
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_122]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
