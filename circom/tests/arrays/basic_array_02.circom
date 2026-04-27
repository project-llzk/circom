// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @bs : !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:        struct.member @bs$inputs : !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:        struct.member @c : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_12]]] = %[[VAL_10]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_14]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_15]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_19]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:          pod.write %[[VAL_20]][@count] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// CHECK-NEXT:          scf.if %[[VAL_25]] {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_27]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_20]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_30]]] = %[[VAL_20]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_32]], @params = %[[VAL_31]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_35]]] = %[[VAL_33]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_37]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_38]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_40]]] = %[[VAL_38]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_42]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:          pod.write %[[VAL_43]][@count] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          scf.if %[[VAL_48]] {
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_50]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_43]][@comp] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_53]]] = %[[VAL_43]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_55]], @params = %[[VAL_54]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_58]]] = %[[VAL_56]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_60]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_61]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_63]]] = %[[VAL_61]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_65]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:          pod.write %[[VAL_66]][@count] = %[[VAL_69]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:          scf.if %[[VAL_71]] {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_73]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_66]][@comp] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_76]]] = %[[VAL_66]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_4]][@x] = %[[VAL_0]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_77]], %[[VAL_78]] : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_79]] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_79]], %[[VAL_80]] : index
// CHECK-NEXT:          scf.if %[[VAL_81]] {
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_83]]) : (!felt.type<"bn128">) -> !struct.type<@C::@C<[]>>
// CHECK-NEXT:            pod.write %[[VAL_7]][@comp] = %[[VAL_84]] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_86]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_88]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_91]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_97]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_95]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@y] = %[[VAL_104]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@bs$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]] to %[[VAL_106]] step %[[VAL_108]] {
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_109]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            array.write %[[VAL_105]]{{\[}}%[[VAL_109]]] = %[[VAL_111]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@bs] = %[[VAL_105]] : <@A::@A<[]>>, !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_112]] : <@A::@A<[]>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_113:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@y] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@bs] : <@A::@A<[]>>, !array.type<3 x !struct.type<@B::@B<[]>>>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@bs$inputs] : <@A::@A<[]>>, !array.type<3 x !pod.type<[@x: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@c] : <@A::@A<[]>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@c$inputs] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_121]], @params = %[[VAL_120]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_124]], @params = %[[VAL_123]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_127]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_131]], @params = %[[VAL_130]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_134]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_136]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_138]], @params = %[[VAL_137]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_141]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_144]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_146]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_147]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_150]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_151]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_148]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_155]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_153]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_118]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_158]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_115]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_164:[0-9a-zA-Z_\.]+]] = %[[VAL_162]] to %[[VAL_161]] step %[[VAL_163]] {
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_164]]] : <3 x !struct.type<@B::@B<[]>>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_164]]] : <3 x !pod.type<[@x: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @B::@B::@constrain(%[[VAL_165]], %[[VAL_167]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @C::@C::@constrain(%[[VAL_118]], %[[VAL_168]]) : (!struct.type<@C::@C<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_169:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_169]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_170]][@y] = %[[VAL_171]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_170]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_172:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_173:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@y] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_173]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_174]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_176:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_176]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_177]][@y] = %[[VAL_178]] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_177]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_179:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_180:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_179]][@y] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_180]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_181]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
