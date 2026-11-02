// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.1.6;

bus A(){
    signal x;
    signal y;
}

template B(){
    A() input in;
    output A() {tag} out;
    out.tag = 2;
    out <== in;
}

component main = B();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_0::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @B_0 {
// CONCRETE-NEXT:      struct.def @B_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@B_0::@B_0<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        struct.member @out.x : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.y : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.x"}, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.y"}) -> !struct.type<@B_0::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_9]], @y = %[[VAL_10]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_12]]) : (!pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@"$component"] = %[[VAL_13]] : <@B_0::@"$bus_entry"<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@out.x] = %[[VAL_15]] : <@B_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@out.y] = %[[VAL_16]] : <@B_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_11]] : !struct.type<@B_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@"$bus_entry"<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.x"}, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.y"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_18]], @y = %[[VAL_19]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@"$component"] : <@B_0::@"$bus_entry"<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_21]], %[[VAL_20]]) : (!struct.type<@B_0::@B_0<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out.x] : <@B_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out.y] : <@B_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_22]], @y = %[[VAL_23]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        struct.member @out.x : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.y : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.x"}, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.y"}) -> !struct.type<@B::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_9]], @y = %[[VAL_10]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_12]]) : (!pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@"$component"] = %[[VAL_13]] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@out] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@out.x] = %[[VAL_15]] : <@B::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@out.y] = %[[VAL_16]] : <@B::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_11]] : !struct.type<@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.x"}, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.y"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_18]], @y = %[[VAL_19]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@"$component"] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_21]], %[[VAL_20]]) : (!struct.type<@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out.x] : <@B::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out.y] : <@B::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@B::@B<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_22]], @y = %[[VAL_23]] }  : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
