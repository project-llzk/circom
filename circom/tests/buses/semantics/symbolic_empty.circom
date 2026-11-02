// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A zero dimension forwarded through template parameters compiles in both modes.

pragma circom 2.2.3;
bus Vec(N) { signal x[N]; }
template Empty(N) {
    Vec(N) input in;
    signal output out;
    out <== 7;
}
template Main(N) {
    Vec(N) input in;
    component child = Empty(N);
    child.in <== in;
    signal output out;
    out <== child.out;
}
component main = Main(0);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @Empty_0 {
// CONCRETE-NEXT:      struct.def @Empty_0 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@Empty_0::@Empty_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@Empty_0::@Empty_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@Empty_0::@Empty_0<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@out] : <@Empty_0::@Empty_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_1 {
// CONCRETE-NEXT:      struct.def @Main_1 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @child : !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@Main_1::@Main_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@in] : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @Empty_0::@Empty_0::@compute(%[[VAL_10]]) : (!pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>) -> !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@Empty_0::@Empty_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@in] : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_13]][@in] = %[[VAL_7]] : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@Empty_0::@Empty_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@Empty_0::@Empty_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_8]][@out] = %[[VAL_16]] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_8]][@child$inputs] = %[[VAL_13]] : <@Main_1::@Main_1<[]>>, !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@Empty_0::@Empty_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_8]][@child] = %[[VAL_17]] : <@Main_1::@Main_1<[]>>, !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_8]] : !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_1::@Main_1<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@child] : <@Main_1::@Main_1<[]>>, !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@child$inputs] : <@Main_1::@Main_1<[]>>, !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@in] : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@x] : <[@x: !array.type<0 x !felt.type<"bn128">>]>, !array.type<0 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@x] : <[@x: !array.type<0 x !felt.type<"bn128">>]>, !array.type<0 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_25]] : !array.type<0 x !felt.type<"bn128">>, !array.type<0 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@Empty_0::@Empty_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@in] : <[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @Empty_0::@Empty_0::@constrain(%[[VAL_21]], %[[VAL_27]]) : (!struct.type<@Empty_0::@Empty_0<[]>>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<0 x !felt.type<"bn128">> {function.arg_name = "in.x"}) -> !struct.type<@Main_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_28]] }  : <[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = function.call @Main_1::@Main_1::@compute(%[[VAL_30]]) : (!pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>) -> !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_29]][@"$component"] = %[[VAL_31]] : <@Main_1::@"$bus_entry"<[]>>, !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@out] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_29]][@out] = %[[VAL_32]] : <@Main_1::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_29]] : !struct.type<@Main_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_1::@"$bus_entry"<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<0 x !felt.type<"bn128">> {function.arg_name = "in.x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_34]] }  : <[@x: !array.type<0 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@"$component"] : <@Main_1::@"$bus_entry"<[]>>, !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          function.call @Main_1::@Main_1::@constrain(%[[VAL_36]], %[[VAL_35]]) : (!struct.type<@Main_1::@Main_1<[]>>, !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@out] : <@Main_1::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@out] : <@Main_1::@Main_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_38]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@"$bus_entry"<[0]>>} {
// TEMPLATED-NEXT:    poly.template @Empty {
// TEMPLATED-NEXT:      poly.param @N : index
// TEMPLATED-NEXT:      struct.def @Empty {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@Empty::@Empty<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Empty::@Empty<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@Empty::@Empty<[@N]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@out] : <@Empty::@Empty<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      poly.param @N : index
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @child : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@Main::@Main<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_13]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_16]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_17]] }  : <[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@N] : <[@N: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_20]], %[[VAL_21]] : index
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_22]] -> (!struct.type<@Empty::@Empty<[@N]>>) {
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @Empty::@Empty::@compute(%[[VAL_25]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:            scf.yield %[[VAL_26]] : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = llzk.nondet : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:            scf.yield %[[VAL_27]] : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_18]], @comp = %[[VAL_23]] }  : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@in] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_15]][@in] = %[[VAL_11]] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@count] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_30]], %[[VAL_31]] : index
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_32]], %[[VAL_33]], %[[VAL_31]] : index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_34]], %[[VAL_35]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_36]] {
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@count] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_28]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_41]] {
// TEMPLATED-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@params] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@in] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @Empty::@Empty::@compute(%[[VAL_43]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_28]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@comp] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@Empty::@Empty<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@out] = %[[VAL_46]] : <@Main::@Main<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@child$inputs] = %[[VAL_15]] : <@Main::@Main<[@N]>>, !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@comp] : <[@count: index, @comp: !struct.type<@Empty::@Empty<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_12]][@child] = %[[VAL_47]] : <@Main::@Main<[@N]>>, !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          function.return %[[VAL_12]] : !struct.type<@Main::@Main<[@N]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[@N]>>, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_50]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@Main::@Main<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@child] : <@Main::@Main<[@N]>>, !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@child$inputs] : <@Main::@Main<[@N]>>, !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_55]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@x] : <[@x: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@x] : <[@x: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_58]], %[[VAL_59]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@out] : <@Empty::@Empty<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_52]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.call @Empty::@Empty::@constrain(%[[VAL_53]], %[[VAL_61]]) : (!struct.type<@Empty::@Empty<[@N]>>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@Main::@Main<[@N]>>
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in.x"}) -> !struct.type<@Main::@"$bus_entry"<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@"$bus_entry"<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_64]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_62]] }  : <[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @Main::@Main::@compute(%[[VAL_66]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Main::@Main<[@N]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_63]][@"$component"] = %[[VAL_67]] : <@Main::@"$bus_entry"<[@N]>>, !struct.type<@Main::@Main<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_67]][@out] : <@Main::@Main<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_63]][@out] = %[[VAL_68]] : <@Main::@"$bus_entry"<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_63]] : !struct.type<@Main::@"$bus_entry"<[@N]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@"$bus_entry"<[@N]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in.x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_71]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_70]] }  : <[@x: !array.type<@N x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@"$component"] : <@Main::@"$bus_entry"<[@N]>>, !struct.type<@Main::@Main<[@N]>>
// TEMPLATED-NEXT:          function.call @Main::@Main::@constrain(%[[VAL_74]], %[[VAL_73]]) : (!struct.type<@Main::@Main<[@N]>>, !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@Main::@"$bus_entry"<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@out] : <@Main::@Main<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_76]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
