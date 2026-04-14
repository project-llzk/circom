// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template nbits() {
    signal input in;
    signal output out;
    var n = 1;
    var r = 0;
    while (n-1 < in) {
        r++;
        n *= 2;
    }
    out <-- r;
}

template UnknownLoopComponent() {
    signal input num;
    signal output bits;

    component nb = nbits();
    nb.in <-- num;
    bits <-- nb.out;
}

component main = UnknownLoopComponent();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@UnknownLoopComponent::@UnknownLoopComponent<[]>>} {
// CHECK-NEXT:    poly.template @UnknownLoopComponent {
// CHECK-NEXT:      struct.def @UnknownLoopComponent {
// CHECK-NEXT:        struct.member @bits : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @nb : !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:        struct.member @nb$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@UnknownLoopComponent::@UnknownLoopComponent<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_0]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@count] : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_5]], %[[VAL_6]] : index
// CHECK-NEXT:          pod.write %[[VAL_3]][@count] = %[[VAL_7]] : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          scf.if %[[VAL_9]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @nbits::@nbits::@compute(%[[VAL_10]]) : (!felt.type<"bn128">) -> !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:            pod.write %[[VAL_3]][@comp] = %[[VAL_11]] : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>, !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>, !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@out] : <@nbits::@nbits<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@bits] = %[[VAL_13]] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@nb$inputs] = %[[VAL_4]] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@nbits::@nbits<[]>>, @params: !pod.type<[]>]>, !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@nb] = %[[VAL_14]] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@UnknownLoopComponent::@UnknownLoopComponent<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopComponent::@UnknownLoopComponent<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@bits] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@nb] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@nb$inputs] : <@UnknownLoopComponent::@UnknownLoopComponent<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @nbits::@nbits::@constrain(%[[VAL_18]], %[[VAL_20]]) : (!struct.type<@nbits::@nbits<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @nbits {
// CHECK-NEXT:      struct.def @nbits {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@nbits::@nbits<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@nbits::@nbits<[]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_23]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_29]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_22]][@out] = %[[VAL_25]]#1 : <@nbits::@nbits<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_22]] : !struct.type<@nbits::@nbits<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !struct.type<@nbits::@nbits<[]>>, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@out] : <@nbits::@nbits<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_40]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_43]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_46]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_48]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_53]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
