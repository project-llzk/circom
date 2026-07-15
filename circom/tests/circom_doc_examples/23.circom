// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template Ex(n, m){
   signal input in[n];
   signal output out[m];
   var i = 0;
   while(i < n) {
      out[i] <== in[i];
      i += 1;
   }
}

template A {
   signal input i[4];
   signal output o[4];
   o <== Ex(4,4)(i);
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @o : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @Ex_20_446 : !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:        struct.member @Ex_20_446$inputs : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "i"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_3]], @m = %[[VAL_4]] }  : <[@n: index, @m: index]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_0]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_10]] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:          scf.if %[[VAL_12]] {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@params] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !pod.type<[@n: index, @m: index]>
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @Ex::@Ex::@compute(%[[VAL_14]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:            pod.write %[[VAL_7]][@comp] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@Ex::@Ex<[4, 4]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_17]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@o] = %[[VAL_18]] : <@A::@A<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@Ex_20_446$inputs] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@Ex_20_446] = %[[VAL_19]] : <@A::@A<[]>>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@o] : <@A::@A<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@Ex_20_446] : <@A::@A<[]>>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@Ex_20_446$inputs] : <@A::@A<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_25]], @m = %[[VAL_26]] }  : <[@n: index, @m: index]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_29]], %[[VAL_21]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@out] : <@Ex::@Ex<[4, 4]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_30]] : !array.type<4 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Ex::@Ex::@constrain(%[[VAL_23]], %[[VAL_31]]) : (!struct.type<@Ex::@Ex<[4, 4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Ex {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      struct.def @Ex {
// CHECK-NEXT:        struct.member @out : !array.type<@m x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Ex::@Ex<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@Ex::@Ex<[@n, @m]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_34]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_36]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_42]]) %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_44]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_38]]{{\[}}%[[VAL_46]]] = %[[VAL_45]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_33]][@out] = %[[VAL_38]] : <@Ex::@Ex<[@n, @m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@Ex::@Ex<[@n, @m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !struct.type<@Ex::@Ex<[@n, @m]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_53]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@Ex::@Ex<[@n, @m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_58]], %[[VAL_54]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_59]]) %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_61]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_63]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_64]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
