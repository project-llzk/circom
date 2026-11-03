// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s
// END.

// Equal tags survive runtime branches for both component and local bus layouts.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    signal input choose;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 2;
    right.x.size = 2;
    left.x <== 5;
    right.x <== 7;
    if (choose) { merged <-- left; }
    else { merged <-- right; }
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
    Vec(merged.x.size) output local;
    for (var i = 0; i < merged.x.size; i++) { local.x[i] <== merged.x; }
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@"$bus_entry"<[]>>} {
// CHECK-NEXT:    poly.template @Expand {
// CHECK-NEXT:      poly.param @"$tag$in$x$size" : index
// CHECK-NEXT:      struct.def @Expand {
// CHECK-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand::@Expand<[@"$tag$in$x$size"]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_.-]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_12]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_12]]] = %[[VAL_10]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_4]][@x] = %[[VAL_11]] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_9]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>, %[[VAL_17:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_18]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_16]][@out] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_.-]+]] = %[[VAL_21]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_17]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_20]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_28]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_29]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_25]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @left : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @right : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @merged : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @local : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @child : !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_32:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "choose"}) -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_34]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_34]][@x] = %[[VAL_38]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_36]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_36]][@x] = %[[VAL_40]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_32]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_43]] -> (!pod.type<[@x: !felt.type<"bn128">]>) {
// CHECK-NEXT:            struct.writem %[[VAL_33]][@merged] = %[[VAL_34]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            scf.yield %[[VAL_34]] : !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            struct.writem %[[VAL_33]][@merged] = %[[VAL_36]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            scf.yield %[[VAL_36]] : !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_45]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_47]], @params = %[[VAL_46]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_37]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_37]][@in] = %[[VAL_44]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_52]], %[[VAL_53]], %[[VAL_51]] : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:          scf.if %[[VAL_56]] {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// CHECK-NEXT:            pod.write %[[VAL_48]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:            scf.if %[[VAL_61]] {
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_37]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_63]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:              pod.write %[[VAL_48]][@comp] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_65]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_69]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_33]][@out] = %[[VAL_70]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_73:[0-9a-zA-Z_.-]+]] = %[[VAL_71]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_73]], %[[VAL_74]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_75]]) %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_76:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_44]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_35]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_79]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_78]]{{\[}}%[[VAL_79]]] = %[[VAL_77]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_35]][@x] = %[[VAL_78]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_76]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_33]][@child$inputs] = %[[VAL_37]] : <@Main::@Main<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@child] = %[[VAL_83]] : <@Main::@Main<[]>>, !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@left] = %[[VAL_34]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@right] = %[[VAL_36]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@local] = %[[VAL_35]] : <@Main::@Main<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_84:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>, %[[VAL_85:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "choose"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@left] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@right] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@merged] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@local] : <@Main::@Main<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@child] : <@Main::@Main<[]>>, !struct.type<@Expand::@Expand<[2]>>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@child$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_86]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_87]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_96]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_85]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_98]] {
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_92]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_99]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_88]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_100]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_91]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_102]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_105]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_109:[0-9a-zA-Z_.-]+]] = %[[VAL_107]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_109]], %[[VAL_110]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_111]]) %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_112:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_88]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_90]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_115]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_116]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_112]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_92]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_91]], %[[VAL_119]]) : (!struct.type<@Expand::@Expand<[2]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @"$bus_entry" {
// CHECK-NEXT:        struct.member @"$component" : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @local.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_120:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "choose"}) -> !struct.type<@Main::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@"$bus_entry"<[]>>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = function.call @Main::@Main::@compute(%[[VAL_120]]) : (!felt.type<"bn128">) -> !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_121]][@"$component"] = %[[VAL_122]] : <@Main::@"$bus_entry"<[]>>, !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_122]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_122]][@local] : <@Main::@Main<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_124]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_121]][@out] = %[[VAL_123]] : <@Main::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_121]][@local.x] = %[[VAL_125]] : <@Main::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_121]] : !struct.type<@Main::@"$bus_entry"<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_126:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@"$bus_entry"<[]>>, %[[VAL_127:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "choose"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_126]][@"$component"] : <@Main::@"$bus_entry"<[]>>, !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:          function.call @Main::@Main::@constrain(%[[VAL_128]], %[[VAL_127]]) : (!struct.type<@Main::@Main<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_126]][@out] : <@Main::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_126]][@local.x] : <@Main::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_128]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_131]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_128]][@local] : <@Main::@Main<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_130]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_132]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_133]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_134]], %[[VAL_135]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
