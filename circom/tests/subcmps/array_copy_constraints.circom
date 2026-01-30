// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var acc = 0;
    for (var i = 0; i < n; i++) {
        acc += inp[i];
    }

    outp <== acc;
}

template Caller(n) {
    signal input inp[n];
    signal outp;

    component op = Sum(n);
    op.inp <== inp;

    outp <== op.outp;
}

component main = Caller(5);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Caller<[5]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Caller<[@n]> {
// CHECK-NEXT:      struct.field @outp : !felt.type
// CHECK-NEXT:      struct.field @op : !struct.type<@Sum<[@n]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Caller<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @Sum::@compute(%[[VAL_0]]) : (!array.type<@n x !felt.type>) -> !struct.type<@Sum<[@n]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_3]][@outp] : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_4]] : <@Caller<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@op] = %[[VAL_3]] : <@Caller<[@n]>>, !struct.type<@Sum<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Caller<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[@n]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@outp] : <@Caller<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@op] : <@Caller<[@n]>>, !struct.type<@Sum<[@n]>>
// CHECK-NEXT:        function.call @Sum::@constrain(%[[VAL_8]], %[[VAL_6]]) : (!struct.type<@Sum<[@n]>>, !array.type<@n x !felt.type>) -> ()
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@outp] : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Sum<[@n]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum<[@n]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_15]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_13]])
// CHECK-NEXT:          scf.condition(%[[VAL_19]]) %[[VAL_17]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_22]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_12]][@outp] = %[[VAL_16]]#0 : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_12]] : !struct.type<@Sum<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum<[@n]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_27]][@outp] : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_30]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_29]])
// CHECK-NEXT:          scf.condition(%[[VAL_35]]) %[[VAL_33]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]]
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_38]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_41]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_40]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_43]], %[[VAL_32]]#0 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
