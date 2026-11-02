// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, same buses for all the elements in the heterogeneus array of components.
// The bus contains other buses
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

bus Simple1(){
    signal a;
}

bus Compuesto(){
    signal a;
    Simple1 b;
    Simple c;
}

template A(n){
    Compuesto input in;
    Compuesto output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.a;
        out.b <== in.b;
        out.c.a <== in.c.b;
        out.c.b <== in.c.a;
    }
}

template B(n){
    Compuesto input in[3];
    Compuesto output out[3];

    for (var i = 0; i < 3; i++){
        out[i] <== A(n[i])(in[i]);
    }
}

component main = B([2, 4, 5]);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_3::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_15]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@out] = %[[VAL_17]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.return %[[VAL_18]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_2 {
// CONCRETE-NEXT:      struct.def @A_2 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_36]][@a] = %[[VAL_37]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_36]][@b] = %[[VAL_39]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_43]][@a] = %[[VAL_42]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_36]][@c] = %[[VAL_43]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_47]][@b] = %[[VAL_46]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_36]][@c] = %[[VAL_47]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_35]][@out] = %[[VAL_36]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.return %[[VAL_35]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_3 {
// CONCRETE-NEXT:      struct.def @B_3 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @A_[[MEMBER0:[0-9]+_[0-9]+]] : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:        struct.member @A_[[MEMBER0]]$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {function.arg_name = "in"}) -> !struct.type<@B_3::@B_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.new : <@B_3::@B_3<[]>>
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_70]], @params = %[[VAL_69]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_72]], @params = %[[VAL_69]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_74]], @params = %[[VAL_69]] }  : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_71]], @idx_1 = %[[VAL_73]], @idx_2 = %[[VAL_75]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_76]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_77]], %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_80]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_85]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_87]]) %[[VAL_82]], %[[VAL_83]], %[[VAL_84]], %[[VAL_85]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_91:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_92]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_96]] : index
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_95]], %[[VAL_97]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_99]] : index
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_95]], %[[VAL_100]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_102]] : index
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_95]], %[[VAL_103]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_104]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                pod.write %[[VAL_108]][@in] = %[[VAL_93]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                pod.write %[[VAL_89]][@idx_2] = %[[VAL_108]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@count] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_110]], %[[VAL_111]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_107]][@count] = %[[VAL_112]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_112]], %[[VAL_113]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_114]] {
// CONCRETE-NEXT:                  %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@params] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_117:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_116]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_107]][@comp] = %[[VAL_117]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                pod.write %[[VAL_88]][@idx_2] = %[[VAL_107]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_88]], %[[VAL_89]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_118:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_101]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_120]][@in] = %[[VAL_93]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_89]][@idx_1] = %[[VAL_120]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_122]], %[[VAL_123]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_119]][@count] = %[[VAL_124]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_125]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_126]] {
// CONCRETE-NEXT:                    %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_128]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_119]][@comp] = %[[VAL_129]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_88]][@idx_1] = %[[VAL_119]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_88]], %[[VAL_89]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_130:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_98]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                    %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_132]][@in] = %[[VAL_93]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_89]][@idx_0] = %[[VAL_132]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                    %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_134]], %[[VAL_135]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_131]][@count] = %[[VAL_136]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_136]], %[[VAL_137]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_138]] {
// CONCRETE-NEXT:                      %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                      %[[VAL_141:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_140]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_131]][@comp] = %[[VAL_141]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_88]][@idx_0] = %[[VAL_131]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_88]], %[[VAL_89]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_142]], %[[VAL_143]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_130]]#0, %[[VAL_130]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_118]]#0, %[[VAL_118]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_106]]#0, %[[VAL_106]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_144]], %[[VAL_146]] : index
// CONCRETE-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_145]], %[[VAL_147]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_144]], %[[VAL_149]] : index
// CONCRETE-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_145]], %[[VAL_150]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_144]], %[[VAL_152]] : index
// CONCRETE-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_145]], %[[VAL_153]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {
// CONCRETE-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_154]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_158]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_159]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_151]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                  %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_162]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_163]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_148]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                    %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_167:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_166]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_167]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_168:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_168]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_164]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_160]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_156]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_169]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            array.write %[[VAL_68]]{{\[}}%[[VAL_169]]] = %[[VAL_155]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_90]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_105]]#0, %[[VAL_105]]#1, %[[VAL_174]], %[[VAL_172]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_67]][@A_[[MEMBER0]]$inputs] = %[[VAL_81]]#1 : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_175]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_176]], @idx_1 = %[[VAL_178]], @idx_2 = %[[VAL_180]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_67]][@A_[[MEMBER0]]] = %[[VAL_181]] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_67]][@out] = %[[VAL_68]] : <@B_3::@B_3<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          function.return %[[VAL_67]] : !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_182:[0-9a-zA-Z_\.]+]]: !struct.type<@B_3::@B_3<[]>>, %[[VAL_183:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@A_[[MEMBER0]]] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@A_[[MEMBER0]]$inputs] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_191:[0-9a-zA-Z_\.]+]] = %[[VAL_188]], %[[VAL_192:[0-9a-zA-Z_\.]+]] = %[[VAL_189]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_192]], %[[VAL_193]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_194]]) %[[VAL_191]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_195:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_196:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_197]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_195]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_199]], %[[VAL_201]] : index
// CONCRETE-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_200]], %[[VAL_202]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_199]], %[[VAL_204]] : index
// CONCRETE-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_200]], %[[VAL_205]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_199]], %[[VAL_207]] : index
// CONCRETE-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_200]], %[[VAL_208]] : i1, i1
// CONCRETE-NEXT:            scf.execute_region {
// CONCRETE-NEXT:              scf.if %[[VAL_209]] {
// CONCRETE-NEXT:                %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_212]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_216]], %[[VAL_217]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_220]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                scf.if %[[VAL_206]] {
// CONCRETE-NEXT:                  %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_226]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_229]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_230]], %[[VAL_231]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_234]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_236]], %[[VAL_237]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  scf.if %[[VAL_203]] {
// CONCRETE-NEXT:                    %[[VAL_238:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                    %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_238]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_240]], %[[VAL_241]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_244]], %[[VAL_245]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_246]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_248]], %[[VAL_249]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_246]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_250]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_195]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_252]], %[[VAL_254]] : index
// CONCRETE-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_253]], %[[VAL_255]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_252]], %[[VAL_257]] : index
// CONCRETE-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_253]], %[[VAL_258]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_252]], %[[VAL_260]] : index
// CONCRETE-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_253]], %[[VAL_261]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {
// CONCRETE-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_262]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_265]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_266]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_259]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                  %[[VAL_268:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_269:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_268]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_269]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_270:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_256]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// CONCRETE-NEXT:                    %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_272:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_271]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_272]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_273:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_273]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_270]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_267]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_264]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_274]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_276]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_279]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_280]], %[[VAL_281]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_284]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_286]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_196]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_195]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_291]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_292:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_292]], %[[VAL_294]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_296]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_295]], %[[VAL_297]]) : (!struct.type<@A_1::@A_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_298]], %[[VAL_300]]) : (!struct.type<@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.c.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.c.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_301:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_302:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b.a"}, %[[VAL_303:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.a"}, %[[VAL_304:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.b"}) -> !struct.type<@B_3::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = struct.new : <@B_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_310:[0-9a-zA-Z_\.]+]] = %[[VAL_308]] to %[[VAL_307]] step %[[VAL_309]] {
// CONCRETE-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_301]]{{\[}}%[[VAL_310]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_302]]{{\[}}%[[VAL_310]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_312]] }  : <[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_303]]{{\[}}%[[VAL_310]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_310]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_314]], @b = %[[VAL_315]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_311]], @b = %[[VAL_313]], @c = %[[VAL_316]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            array.write %[[VAL_306]]{{\[}}%[[VAL_310]]] = %[[VAL_317]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_318:[0-9a-zA-Z_\.]+]] = function.call @B_3::@B_3::@compute(%[[VAL_306]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_305]][@"$component"] = %[[VAL_318]] : <@B_3::@"$bus_entry"<[]>>, !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_318]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_327:[0-9a-zA-Z_\.]+]] = %[[VAL_325]] to %[[VAL_324]] step %[[VAL_326]] {
// CONCRETE-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_323]]{{\[}}%[[VAL_327]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_319]]{{\[}}%[[VAL_327]]] = %[[VAL_329]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_330]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_320]]{{\[}}%[[VAL_327]]] = %[[VAL_331]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_321]]{{\[}}%[[VAL_327]]] = %[[VAL_333]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_322]]{{\[}}%[[VAL_327]]] = %[[VAL_334]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_305]][@out.a] = %[[VAL_319]] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_305]][@out.b.a] = %[[VAL_320]] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_305]][@out.c.a] = %[[VAL_321]] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_305]][@out.c.b] = %[[VAL_322]] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_305]] : !struct.type<@B_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_335:[0-9a-zA-Z_\.]+]]: !struct.type<@B_3::@"$bus_entry"<[]>>, %[[VAL_336:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_337:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b.a"}, %[[VAL_338:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.a"}, %[[VAL_339:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_344:[0-9a-zA-Z_\.]+]] = %[[VAL_342]] to %[[VAL_341]] step %[[VAL_343]] {
// CONCRETE-NEXT:            %[[VAL_345:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_344]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_337]]{{\[}}%[[VAL_344]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_346]] }  : <[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_338]]{{\[}}%[[VAL_344]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_339]]{{\[}}%[[VAL_344]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_348]], @b = %[[VAL_349]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_345]], @b = %[[VAL_347]], @c = %[[VAL_350]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            array.write %[[VAL_340]]{{\[}}%[[VAL_344]]] = %[[VAL_351]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@"$component"] : <@B_3::@"$bus_entry"<[]>>, !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          function.call @B_3::@B_3::@constrain(%[[VAL_352]], %[[VAL_340]]) : (!struct.type<@B_3::@B_3<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@out.a] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@out.b.a] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@out.c.a] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@out.c.b] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_352]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_362:[0-9a-zA-Z_\.]+]] = %[[VAL_360]] to %[[VAL_359]] step %[[VAL_361]] {
// CONCRETE-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_362]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_362]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_365:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_364]] }  : <[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_355]]{{\[}}%[[VAL_362]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_356]]{{\[}}%[[VAL_362]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_366]], @b = %[[VAL_367]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_363]], @b = %[[VAL_365]], @c = %[[VAL_368]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            array.write %[[VAL_358]]{{\[}}%[[VAL_362]]] = %[[VAL_369]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_373:[0-9a-zA-Z_\.]+]] = %[[VAL_371]] to %[[VAL_370]] step %[[VAL_372]] {
// CONCRETE-NEXT:            %[[VAL_374:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_357]]{{\[}}%[[VAL_373]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_373]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_375]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_376]], %[[VAL_377]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_375]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_378]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_379]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_380]], %[[VAL_381]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_375]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_382]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_383]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_384]], %[[VAL_385]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_382]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_383]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_386]], %[[VAL_387]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:      global.def const @array_const_1 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @n
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_2]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_5]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_7]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_0]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@a] = %[[VAL_9]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@b] = %[[VAL_11]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_15]][@a] = %[[VAL_14]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@c] = %[[VAL_15]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_19]][@b] = %[[VAL_18]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@c] = %[[VAL_19]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_3]] : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_23]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_26]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_28]] {
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_29]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_42]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_45]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_50]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_54]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.expr @"anon_var_[[MEMBER0:[0-9]+_[0-9]+]]@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_56]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @A_[[MEMBER1:[0-9]+_[0-9]+]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @A_[[MEMBER1]]$inputs : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_59]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_62]], %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_63]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_65]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_72]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_73]]) %[[VAL_68]], %[[VAL_69]], %[[VAL_70]], %[[VAL_71]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_78]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_79]] }  : <[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_82]], @params = %[[VAL_81]] } (%[[VAL_80]]) : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_74]]{{\[}}%[[VAL_84]]] = %[[VAL_83]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_85]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_87]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_87]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            pod.write %[[VAL_88]][@in] = %[[VAL_86]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_91]], %[[VAL_92]] : index
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_93]], %[[VAL_94]], %[[VAL_92]] : index
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_95]], %[[VAL_96]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_97]] {
// TEMPLATED-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// TEMPLATED-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_98]], %[[VAL_99]] : index
// TEMPLATED-NEXT:              pod.write %[[VAL_89]][@count] = %[[VAL_100]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_100]], %[[VAL_101]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_102]] {
// TEMPLATED-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_104]]) {(%[[VAL_106]])} : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                pod.write %[[VAL_89]][@comp] = %[[VAL_107]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            array.write %[[VAL_75]]{{\[}}%[[VAL_87]]] = %[[VAL_88]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_74]]{{\[}}%[[VAL_87]]] = %[[VAL_89]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_108]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_110]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_112]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_61]]{{\[}}%[[VAL_112]]] = %[[VAL_111]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_76]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_74]], %[[VAL_75]], %[[VAL_117]], %[[VAL_115]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@A_[[MEMBER1]]$inputs] = %[[VAL_67]]#1 : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_120]] to %[[VAL_119]] step %[[VAL_121]] {
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]#0{{\[}}%[[VAL_122]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_118]]{{\[}}%[[VAL_122]]] = %[[VAL_124]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@A_[[MEMBER1]]] = %[[VAL_118]] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@out] = %[[VAL_61]] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          function.return %[[VAL_58]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_125:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_127]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_125]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_125]][@A_[[MEMBER1]]] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_125]][@A_[[MEMBER1]]$inputs] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_133]], %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_134]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_137]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_139]]) %[[VAL_136]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_142]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_126]]{{\[}}%[[VAL_145]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_147]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_150]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_154]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_158]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_160]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_162]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_163]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_167]], %[[VAL_168]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_171]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_175]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_177]], %[[VAL_178]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_141]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_140]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_182]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_186:[0-9a-zA-Z_\.]+]] = %[[VAL_184]] to %[[VAL_183]] step %[[VAL_185]] {
// TEMPLATED-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_186]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_186]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_187]], %[[VAL_189]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.c.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.c.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_190:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_191:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b.a"}, %[[VAL_192:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.a"}, %[[VAL_193:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.b"}) -> !struct.type<@B::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_195]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_199]] to %[[VAL_198]] step %[[VAL_200]] {
// TEMPLATED-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_190]]{{\[}}%[[VAL_201]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_191]]{{\[}}%[[VAL_201]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_203]] }  : <[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_192]]{{\[}}%[[VAL_201]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_193]]{{\[}}%[[VAL_201]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_205]], @b = %[[VAL_206]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_202]], @b = %[[VAL_204]], @c = %[[VAL_207]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_197]]{{\[}}%[[VAL_201]]] = %[[VAL_208]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_197]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_194]][@"$component"] = %[[VAL_209]] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_218:[0-9a-zA-Z_\.]+]] = %[[VAL_216]] to %[[VAL_215]] step %[[VAL_217]] {
// TEMPLATED-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_214]]{{\[}}%[[VAL_218]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_210]]{{\[}}%[[VAL_218]]] = %[[VAL_220]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_211]]{{\[}}%[[VAL_218]]] = %[[VAL_222]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_212]]{{\[}}%[[VAL_218]]] = %[[VAL_224]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_213]]{{\[}}%[[VAL_218]]] = %[[VAL_225]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_194]][@out.a] = %[[VAL_210]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_194]][@out.b.a] = %[[VAL_211]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_194]][@out.c.a] = %[[VAL_212]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_194]][@out.c.b] = %[[VAL_213]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_194]] : !struct.type<@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_226:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[]>>, %[[VAL_227:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_228:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b.a"}, %[[VAL_229:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.a"}, %[[VAL_230:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.c.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_231]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_237:[0-9a-zA-Z_\.]+]] = %[[VAL_235]] to %[[VAL_234]] step %[[VAL_236]] {
// TEMPLATED-NEXT:            %[[VAL_238:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_237]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_228]]{{\[}}%[[VAL_237]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_239]] }  : <[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_237]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_230]]{{\[}}%[[VAL_237]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_241]], @b = %[[VAL_242]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_238]], @b = %[[VAL_240]], @c = %[[VAL_243]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_233]]{{\[}}%[[VAL_237]]] = %[[VAL_244]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@"$component"] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_245]], %[[VAL_233]]) : (!struct.type<@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@out.a] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@out.b.a] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@out.c.a] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@out.c.b] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_245]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_255:[0-9a-zA-Z_\.]+]] = %[[VAL_253]] to %[[VAL_252]] step %[[VAL_254]] {
// TEMPLATED-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_246]]{{\[}}%[[VAL_255]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_247]]{{\[}}%[[VAL_255]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_257]] }  : <[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_248]]{{\[}}%[[VAL_255]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_255]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_259]], @b = %[[VAL_260]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_256]], @b = %[[VAL_258]], @c = %[[VAL_261]] }  : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_251]]{{\[}}%[[VAL_255]]] = %[[VAL_262]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_266:[0-9a-zA-Z_\.]+]] = %[[VAL_264]] to %[[VAL_263]] step %[[VAL_265]] {
// TEMPLATED-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_250]]{{\[}}%[[VAL_266]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_268:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_251]]{{\[}}%[[VAL_266]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_267]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_268]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_269]], %[[VAL_270]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_267]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_272:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_268]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_271]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_273]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_267]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_268]][@c] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_276]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_277]], %[[VAL_278]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_276]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_279]], %[[VAL_280]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
