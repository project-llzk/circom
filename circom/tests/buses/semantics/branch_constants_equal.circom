// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Equal values survive merging, including an implicit else and untouched locals.
pragma circom 2.2.3;

bus Pair() { signal {size} x[2]; }

template Main(CHOOSE) {
    signal {size} s;
    s.size = 7;
    s <== 3;
    Pair() a;
    Pair() b;
    Pair() c;
    var bound;
    var unchanged = 2;
    var implicit = 2;
    if (CHOOSE) { bound = 1 + 1; }
    else { bound = 2; }
    if (CHOOSE) { implicit = 2; }
    for (var i = 0; i < bound; i++) { a.x[i] <== s; }
    for (var j = 0; j < unchanged; j++) { b.x[j] <== s; }
    for (var k = 0; k < implicit; k++) { c.x[k] <== s; }
    signal output out;
    out <== a.x.size + b.x.size + c.x.size;
}

component main = Main(0);

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[0]>>} {
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      poly.param @CHOOSE
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @a : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// TEMPLATED-NEXT:        struct.member @b : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// TEMPLATED-NEXT:        struct.member @c : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[@CHOOSE]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[@CHOOSE]>>
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@s] = %[[VAL_5]] : <@Main::@Main<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_1]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_9]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_13]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_1]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_16]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            scf.yield %[[VAL_7]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_21:[0-9a-zA-Z_.-]+]] = %[[VAL_19]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_21]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_25]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_25]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_2]][@x] = %[[VAL_24]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_23]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_28]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_31:[0-9a-zA-Z_.-]+]] = %[[VAL_29]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_32]]) %[[VAL_31]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_33:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_35]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_34]]{{\[}}%[[VAL_35]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@x] = %[[VAL_34]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_33]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_.-]+]] = %[[VAL_39]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_42]]) %[[VAL_41]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_43:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_45:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_46:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_44]]{{\[}}%[[VAL_45]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_4]][@x] = %[[VAL_44]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_47:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_43]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_48]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_51]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_53]] : <@Main::@Main<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_2]] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@b] = %[[VAL_3]] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_4]] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_0]] : !struct.type<@Main::@Main<[@CHOOSE]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_54:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[@CHOOSE]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_54]][@s] : <@Main::@Main<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_54]][@a] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_54]][@b] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_54]][@c] : <@Main::@Main<[@CHOOSE]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_54]][@out] : <@Main::@Main<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_55]], %[[VAL_64]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_65]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_68:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_69:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_67]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_69]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_70:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_55]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_72]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            scf.yield %[[VAL_63]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_77:[0-9a-zA-Z_.-]+]] = %[[VAL_75]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_78:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_77]], %[[VAL_66]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_78]]) %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_79:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_80:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_57]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_81]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_82]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_84:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_79]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_84]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_87:[0-9a-zA-Z_.-]+]] = %[[VAL_85]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_87]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_88]]) %[[VAL_87]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_89:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_58]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_91:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_91]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_92]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_89]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_94]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_97:[0-9a-zA-Z_.-]+]] = %[[VAL_95]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_97]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_98]]) %[[VAL_97]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_99:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_59]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_100]]{{\[}}%[[VAL_101]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_102]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_99]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_104]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_105]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_107]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_60]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_0::@Main_0<[]>>} {
// CONCRETE-NEXT:    poly.template @Main_0 {
// CONCRETE-NEXT:      struct.def @Main_0 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CONCRETE-NEXT:        struct.member @b : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CONCRETE-NEXT:        struct.member @c : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@s] = %[[VAL_4]] : <@Main_0::@Main_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_.-]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_8:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_1]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_12]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_12]]] = %[[VAL_4]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_1]][@x] = %[[VAL_11]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_15:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_10]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_18:[0-9a-zA-Z_.-]+]] = %[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_20]]) %[[VAL_18]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_21:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_23:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_23]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_22]]{{\[}}%[[VAL_23]]] = %[[VAL_4]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_2]][@x] = %[[VAL_22]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_21]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_26]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_29:[0-9a-zA-Z_.-]+]] = %[[VAL_27]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_29]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_29]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_34]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_33]]{{\[}}%[[VAL_34]]] = %[[VAL_4]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_3]][@x] = %[[VAL_33]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_32]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_37]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.const  21 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_38]] : <@Main_0::@Main_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_1]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@b] = %[[VAL_2]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_3]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_0]] : !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_39:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_0::@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_39]][@out] : <@Main_0::@Main_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_39]][@s] : <@Main_0::@Main_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_39]][@a] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_39]][@b] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_39]][@c] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_48:[0-9a-zA-Z_.-]+]] = %[[VAL_46]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_48]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_50]]) %[[VAL_48]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_51:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_53:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_54:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_53]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_54]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_51]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_56]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_59:[0-9a-zA-Z_.-]+]] = %[[VAL_57]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_60]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_61]]) %[[VAL_59]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_62:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_43]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_64:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_65:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_64]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_65]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_66:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_62]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_67]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_70:[0-9a-zA-Z_.-]+]] = %[[VAL_68]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_70]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_72]]) %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_73:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_74:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_44]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_75:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_76:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_75]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_76]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_77:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_78:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_73]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_78]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = felt.const  21 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }
