// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@UnknownLoopComponent<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @UnknownLoopComponent<[]> {
// CHECK-NEXT:      struct.field @bits : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @nb : !struct.type<@nbits<[]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@UnknownLoopComponent<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopComponent<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @nbits::@compute(%[[VAL_0]]) : (!felt.type) -> !struct.type<@nbits<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@out] : <@nbits<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@bits] = %[[VAL_3]] : <@UnknownLoopComponent<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@nb] = %[[VAL_2]] : <@UnknownLoopComponent<[]>>, !struct.type<@nbits<[]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@UnknownLoopComponent<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopComponent<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@bits] : <@UnknownLoopComponent<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@nb] : <@UnknownLoopComponent<[]>>, !struct.type<@nbits<[]>>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:        function.call @nbits::@constrain(%[[VAL_6]], %[[VAL_7]]) : (!struct.type<@nbits<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @nbits<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@nbits<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@nbits<[]>>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_9]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_14]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_19]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_10]][@out] = %[[VAL_13]]#1 : <@nbits<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_10]] : !struct.type<@nbits<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@nbits<[]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_25]][@out] : <@nbits<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_27]], %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_30]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_33]], %[[VAL_26]])
// CHECK-NEXT:          scf.condition(%[[VAL_34]]) %[[VAL_30]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_35]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_40]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
