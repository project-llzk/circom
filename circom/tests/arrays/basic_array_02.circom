// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input x;
    signal output y;

    y <== x * x;
}

template C() {
    signal input x;
    signal output y;

    y <== x + x;
}

template A() {
    signal input x;
    signal output y;
    component c = C();
    component bs[3];

    bs[0] = B();
    bs[0].x <== x;

    bs[1] = B();
    bs[1].x <== x;

    bs[2] = B();
    bs[2].x <== x;

    c.x <== x;

    y <== bs[0].y + bs[1].y + bs[2].y + c.y;
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @bs : !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:        struct.member @bs$inputs : !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        struct.member @c : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_7]]] = %[[VAL_9]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]], @params = %[[VAL_15]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]], @params = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_24]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_25]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_27]]] = %[[VAL_25]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_29]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_32]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:          pod.write %[[VAL_30]][@count] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:          scf.if %[[VAL_38]] {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_40]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_30]][@comp] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_43]]] = %[[VAL_30]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_45]], @params = %[[VAL_44]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_48]]] = %[[VAL_46]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_50]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_51]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_53]]] = %[[VAL_51]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_55]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_58]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:          pod.write %[[VAL_56]][@count] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:          scf.if %[[VAL_64]] {
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_66]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_56]][@comp] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_69]]] = %[[VAL_56]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_71]], @params = %[[VAL_70]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_74]]] = %[[VAL_72]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_76]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_77]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_79]]] = %[[VAL_77]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_81]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_84]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_86]], %[[VAL_87]] : index
// CHECK-NEXT:          pod.write %[[VAL_82]][@count] = %[[VAL_88]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_89]] : index
// CHECK-NEXT:          scf.if %[[VAL_90]] {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_92]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_82]][@comp] = %[[VAL_93]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_95]]] = %[[VAL_82]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_14]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_96]], %[[VAL_97]] : index
// CHECK-NEXT:          pod.write %[[VAL_17]][@count] = %[[VAL_98]] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_98]], %[[VAL_99]] : index
// CHECK-NEXT:          scf.if %[[VAL_100]] {
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_102]]) : (!felt.type<"bn128">) -> !struct.type<@C::@C<[]>>
// CHECK-NEXT:            pod.write %[[VAL_17]][@comp] = %[[VAL_103]] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_105]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_110]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_112]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_116]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_118]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_121]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_120]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@y] = %[[VAL_123]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@bs$inputs] = %[[VAL_10]] : <@A::@A<[]>>, !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_128:[0-9a-zA-Z_\.]+]] = %[[VAL_126]] to %[[VAL_125]] step %[[VAL_127]] {
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_128]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            array.write %[[VAL_124]]{{\[}}%[[VAL_128]]] = %[[VAL_130]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@bs] = %[[VAL_124]] : <@A::@A<[]>>, !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c$inputs] = %[[VAL_14]] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_131]] : <@A::@A<[]>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_132:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_133:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@y] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@bs] : <@A::@A<[]>>, !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@bs$inputs] : <@A::@A<[]>>, !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@c] : <@A::@A<[]>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_132]][@c$inputs] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_144]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_146]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_150]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_152]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_156]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_158]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_159]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_161]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_162]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_165]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_166]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_163]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_170]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_168]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_137]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_173]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_134]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_179:[0-9a-zA-Z_\.]+]] = %[[VAL_177]] to %[[VAL_176]] step %[[VAL_178]] {
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_179]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @B::@B::@constrain(%[[VAL_180]], %[[VAL_182]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @C::@C::@constrain(%[[VAL_137]], %[[VAL_183]]) : (!struct.type<@C::@C<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_184:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_184]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_185]][@y] = %[[VAL_186]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_185]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_187:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_188:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_187]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_188]], %[[VAL_188]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_189]], %[[VAL_190]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_191:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_191]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_192]][@y] = %[[VAL_193]] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_192]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_194:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_195:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_194]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_195]], %[[VAL_195]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_196]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
