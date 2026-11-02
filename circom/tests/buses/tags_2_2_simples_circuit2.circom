// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.0;

bus S(){
    signal {a} aux;
}

template A(){
    input S() {b} inter;

    inter.b === 2;
    output S() {b} out <== inter;
}

template B(){
    component a = A();
    S() {b} prueba; prueba.b = 2; prueba.aux <== 1;
    a.inter <== prueba;
    a.out.b === 2;
}

component main = B();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_1::@B_1<[]>>} {
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@aux: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@aux: !felt.type<"bn128">]> {function.arg_name = "inter"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@aux: !felt.type<"bn128">]> {function.arg_name = "inter"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @prueba : !pod.type<[@aux: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @a : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        struct.member @a$inputs : !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_10]][@aux] = %[[VAL_15]] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_14]][@inter] = %[[VAL_10]] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_20]], %[[VAL_21]], %[[VAL_19]] : index
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_24]] {
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_13]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_29]] {
// CONCRETE-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_31]]) : (!pod.type<[@aux: !felt.type<"bn128">]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_13]][@comp] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_9]][@a$inputs] = %[[VAL_14]] : <@B_1::@B_1<[]>>, !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_9]][@a] = %[[VAL_33]] : <@B_1::@B_1<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_9]][@prueba] = %[[VAL_10]] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_9]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@prueba] : <@B_1::@B_1<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@a] : <@B_1::@B_1<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@a$inputs] : <@B_1::@B_1<[]>>, !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_36]], %[[VAL_45]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @"$tag$inter$aux$a"
// TEMPLATED-NEXT:      poly.param @"$tag$inter$b"
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@aux: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@aux: !felt.type<"bn128">]> {function.arg_name = "inter"}) -> !struct.type<@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$b" : !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !pod.type<[@aux: !felt.type<"bn128">]> {function.arg_name = "inter"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$aux$a" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$inter$b" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@A::@A<[@"$tag$inter$aux$a", @"$tag$inter$b"]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_10]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @prueba : !pod.type<[@aux: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @a : !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:        struct.member @a$inputs : !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$inter$aux$a" = %[[VAL_15]], @"$tag$inter$b" = %[[VAL_16]] }  : <[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_13]][@aux] = %[[VAL_20]] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_14]][@inter] = %[[VAL_13]] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_25]], %[[VAL_26]], %[[VAL_24]] : index
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_29]] {
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_30]], %[[VAL_31]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_19]][@count] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_34]] {
// TEMPLATED-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_36]]) : (!pod.type<[@aux: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_19]][@comp] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@a$inputs] = %[[VAL_14]] : <@B::@B<[]>>, !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[0, 2]>>, @params: !pod.type<[@"$tag$inter$aux$a": !felt.type<"bn128">, @"$tag$inter$b": !felt.type<"bn128">]>]>, !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@a] = %[[VAL_38]] : <@B::@B<[]>>, !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@prueba] = %[[VAL_13]] : <@B::@B<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_12]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_39]][@prueba] : <@B::@B<[]>>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_39]][@a] : <@B::@B<[]>>, !struct.type<@A::@A<[0, 2]>>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_39]][@a$inputs] : <@B::@B<[]>>, !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@aux] : <[@aux: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_48]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@inter] : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_41]], %[[VAL_50]]) : (!struct.type<@A::@A<[0, 2]>>, !pod.type<[@aux: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
