// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.0;
bus S2(){
    signal {a} aux[1];
}
bus S(){
    S2 {b} aux[1];
}

template A(){
    input S() {c} inter[1];
    //input signal {c} aux2;
    log(inter.c);
    inter.c === 3;
    log(inter.aux.b);
    inter.aux.b === 4;
    log(inter.aux.aux.a);
    inter.aux.aux.a === 5;
    signal output {c} out2[inter.c]; //using the value of inter.c to define the size of out2
    out2.c = inter.c + inter.aux.aux.a;
    for(var i = 0; i < inter.c; i++){
        out2[i] <== 0;
    }
    log(out2.c);
    out2.c === 8;
    output S() {c} out <== inter[0];
}

template B(){
    component a[1];
    a[0] = A();
    signal {a} anda; anda.a = 5; anda <== 3;
    S2() {b} prueba2; prueba2.b = 4;
    S() {c} prueba; prueba.c = 3;
    prueba2.aux[0] <== anda;
    prueba.aux[0] <== prueba2;

    a[0].inter[0] <== prueba;
    //log(a[0].out.aux[0].a); //First, it fails since a is not defined in S(). It should be b.
    //log(a[0].out.aux[0].b); //When used correctly, it fails since tags should not be used with array accesses but in the component array.
    //log(a[0].out.aux.b.a); //When used correctly, it fails since after a tag cannot be accessed anything else.
    log(a[0].out2.c); //When used correctly,
    a[0].out2.c === 8;
    log(a[0].out.aux.aux.a); //When used correctly,
    a[0].out.aux.aux.a === 5;
    log(a[0].out.aux.b); //When used correctly,
    a[0].out.aux.b === 4;
    log(a[0].out.c); //When used correctly,
    a[0].out.c === 3;
}

component main = B();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_1::@B_1<[]>>} {
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out2 : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>> {function.arg_name = "inter"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_5]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_10]]] = %[[VAL_9]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_12]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_14]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_15]] : <@A_0::@A_0<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out2] = %[[VAL_2]] : <@A_0::@A_0<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>> {function.arg_name = "inter"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out2] : <@A_0::@A_0<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_33]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_34]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_36]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_40]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_45]] to %[[VAL_44]] step %[[VAL_46]] {
// CONCRETE-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_47]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_47]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_50]], %[[VAL_51]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @anda : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @prueba2 : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]> {signal}
// CONCRETE-NEXT:        struct.member @prueba : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]> {signal}
// CONCRETE-NEXT:        struct.member @a : !array.type<1 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:        struct.member @a$inputs : !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_61]], @params = %[[VAL_56]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_60]]] = %[[VAL_62]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_52]][@anda] = %[[VAL_64]] : <@B_1::@B_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_67]]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_65]]{{\[}}%[[VAL_67]]] = %[[VAL_64]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_54]][@aux] = %[[VAL_65]] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_71]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          array.write %[[VAL_69]]{{\[}}%[[VAL_71]]] = %[[VAL_54]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_53]][@aux] = %[[VAL_69]] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_74]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_74]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_79]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          array.write %[[VAL_77]]{{\[}}%[[VAL_79]]] = %[[VAL_53]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          pod.write %[[VAL_75]][@inter] = %[[VAL_77]] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_81]], %[[VAL_82]] : index
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_83]], %[[VAL_84]], %[[VAL_82]] : index
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_85]], %[[VAL_86]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_87]] {
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_88]], %[[VAL_89]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_76]][@count] = %[[VAL_90]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_90]], %[[VAL_91]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_92]] {
// CONCRETE-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_94]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_76]][@comp] = %[[VAL_95]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          array.write %[[VAL_63]]{{\[}}%[[VAL_74]]] = %[[VAL_75]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// CONCRETE-NEXT:          array.write %[[VAL_55]]{{\[}}%[[VAL_74]]] = %[[VAL_76]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_52]][@a$inputs] = %[[VAL_63]] : <@B_1::@B_1<[]>>, !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_98]] to %[[VAL_97]] step %[[VAL_99]] {
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_100]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            array.write %[[VAL_96]]{{\[}}%[[VAL_100]]] = %[[VAL_102]] : <1 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_52]][@a] = %[[VAL_96]] : <@B_1::@B_1<[]>>, !array.type<1 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          struct.writem %[[VAL_52]][@prueba2] = %[[VAL_54]] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_52]][@prueba] = %[[VAL_53]] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_52]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@anda] : <@B_1::@B_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@prueba2] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@prueba] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@a] : <@B_1::@B_1<[]>>, !array.type<1 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@a$inputs] : <@B_1::@B_1<[]>>, !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_104]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_110]]{{\[}}%[[VAL_112]]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_113]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_116]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_118]], %[[VAL_119]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_121]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_125]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_130]] to %[[VAL_129]] step %[[VAL_131]] {
// CONCRETE-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_132]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_132]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_135]], %[[VAL_136]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_137]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_139]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_141]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_148:[0-9a-zA-Z_\.]+]] = %[[VAL_146]] to %[[VAL_145]] step %[[VAL_147]] {
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_148]]] : <1 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_148]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// CONCRETE-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:            function.call @A_0::@A_0::@constrain(%[[VAL_149]], %[[VAL_151]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> ()
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @"$tag$inter$aux$aux$a"
// TEMPLATED-NEXT:      poly.param @"$tag$inter$aux$b"
// TEMPLATED-NEXT:      poly.param @"$tag$inter$c" : index
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out2 : !array.type<@"$tag$inter$c" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>> {function.arg_name = "inter"}) -> !struct.type<@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$aux$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$b" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$c" : index
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_4]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@"$tag$inter$c" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_5]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_9]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_6]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <@"$tag$inter$c" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_17]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_18]] : <@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out2] = %[[VAL_6]] : <@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>, !array.type<@"$tag$inter$c" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>> {function.arg_name = "inter"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$aux$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$b" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$c" : index
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_23]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out2] : <@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>, !array.type<@"$tag$inter$c" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@A::@A<[@"$tag$inter$aux$aux$a", @"$tag$inter$aux$b", @"$tag$inter$c"]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_21]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_33]]) %[[VAL_32]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_36]]] : <@"$tag$inter$c" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_37]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_39]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_43]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_48]] to %[[VAL_47]] step %[[VAL_49]] {
// TEMPLATED-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_50]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_50]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_53]], %[[VAL_54]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @anda : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @prueba2 : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]> {signal}
// TEMPLATED-NEXT:        struct.member @prueba : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]> {signal}
// TEMPLATED-NEXT:        struct.member @a : !array.type<1 x !struct.type<@A::@A<[5, 4, 3]>>>
// TEMPLATED-NEXT:        struct.member @a$inputs : !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$inter$aux$aux$a" = %[[VAL_60]], @"$tag$inter$aux$b" = %[[VAL_61]], @"$tag$inter$c" = %[[VAL_62]] }  : <[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_64]], @params = %[[VAL_63]] }  : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_67]]] = %[[VAL_65]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_55]][@anda] = %[[VAL_68]] : <@B::@B<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_71]]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_69]]{{\[}}%[[VAL_71]]] = %[[VAL_68]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_57]][@aux] = %[[VAL_69]] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_75]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          array.write %[[VAL_73]]{{\[}}%[[VAL_75]]] = %[[VAL_57]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_56]][@aux] = %[[VAL_73]] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_78]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_78]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_83]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          array.write %[[VAL_81]]{{\[}}%[[VAL_83]]] = %[[VAL_56]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_79]][@inter] = %[[VAL_81]] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_85]], %[[VAL_86]] : index
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_87]], %[[VAL_88]], %[[VAL_86]] : index
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_89]], %[[VAL_90]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_91]] {
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_92]], %[[VAL_93]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_80]][@count] = %[[VAL_94]] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_95]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_96]] {
// TEMPLATED-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_98]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_80]][@comp] = %[[VAL_99]] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_59]]{{\[}}%[[VAL_78]]] = %[[VAL_79]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// TEMPLATED-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_78]]] = %[[VAL_80]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_55]][@a$inputs] = %[[VAL_59]] : <@B::@B<[]>>, !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@A::@A<[5, 4, 3]>>>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_104]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[5, 4, 3]>>, @params: !pod.type<[@"$tag$inter$aux$aux$a": !felt.type<"bn128">, @"$tag$inter$aux$b": !felt.type<"bn128">, @"$tag$inter$c": !felt.type<"bn128">]>]>, !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED-NEXT:            array.write %[[VAL_100]]{{\[}}%[[VAL_104]]] = %[[VAL_106]] : <1 x !struct.type<@A::@A<[5, 4, 3]>>>, !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_55]][@a] = %[[VAL_100]] : <@B::@B<[]>>, !array.type<1 x !struct.type<@A::@A<[5, 4, 3]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_55]][@prueba2] = %[[VAL_57]] : <@B::@B<[]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_55]][@prueba] = %[[VAL_56]] : <@B::@B<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_55]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@anda] : <@B::@B<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@prueba2] : <@B::@B<[]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@prueba] : <@B::@B<[]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@a] : <@B::@B<[]>>, !array.type<1 x !struct.type<@A::@A<[5, 4, 3]>>>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@a$inputs] : <@B::@B<[]>>, !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_108]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_116]]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_117]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_120]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_122]], %[[VAL_123]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_125]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_129]]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@aux] : <[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_134]] to %[[VAL_133]] step %[[VAL_135]] {
// TEMPLATED-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_136]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_136]]] : <1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>, !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@aux] : <[@aux: !array.type<1 x !felt.type<"bn128">>]>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_139]], %[[VAL_140]] : !array.type<1 x !felt.type<"bn128">>, !array.type<1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_141]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_145]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_147]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_150]] to %[[VAL_149]] step %[[VAL_151]] {
// TEMPLATED-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_152]]] : <1 x !struct.type<@A::@A<[5, 4, 3]>>>, !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_152]]] : <1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>, !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>
// TEMPLATED-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@inter] : <[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_153]], %[[VAL_155]]) : (!struct.type<@A::@A<[5, 4, 3]>>, !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
