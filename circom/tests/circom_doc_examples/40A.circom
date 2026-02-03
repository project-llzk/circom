// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

template check_bits(n) {
  signal input in;
  component check = Num2Bits(n);
  check.in <== in;
}

component main = check_bits(10);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@check_bits<[10]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Num2Bits<[@n]> {
// CHECK-NEXT:      struct.field @out : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_11]]) %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_15]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_18]]] = %[[VAL_17]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_19]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_23]], %[[VAL_25]], %[[VAL_22]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@Num2Bits<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits<[@n]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_26]][@out] : <@Num2Bits<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_28]])
// CHECK-NEXT:          scf.condition(%[[VAL_37]]) %[[VAL_34]], %[[VAL_35]], %[[VAL_36]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_41]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_43]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_44]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_42]], %[[VAL_46]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_48]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_49]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_50]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_51]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_53]], %[[VAL_55]], %[[VAL_52]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_33]]#2, %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @check_bits<[@n]> {
// CHECK-NEXT:      struct.field @check : !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@check_bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.new : <@check_bits<[@n]>>
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@compute(%[[VAL_56]]) : (!felt.type) -> !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:        struct.writef %[[VAL_57]][@check] = %[[VAL_59]] : <@check_bits<[@n]>>, !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_57]] : !struct.type<@check_bits<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@check_bits<[@n]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_60]][@check] : <@check_bits<[@n]>>, !struct.type<@Num2Bits<[@n]>>
// CHECK-NEXT:        function.call @Num2Bits::@constrain(%[[VAL_63]], %[[VAL_61]]) : (!struct.type<@Num2Bits<[@n]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
