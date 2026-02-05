// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

template A() {
    signal input a;
    signal input b;
    signal input d;
    signal output c;
    signal x;

    component cb = B();
    cb.a <== a;
    cb.b <== b;

    x <== cb.c;
    c <== x * d;
}

component main {public [a, b]} = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @x : !felt.type
// CHECK-NEXT:      struct.field @cb : !struct.type<@B<[]>>
// CHECK-NEXT:      struct.field @cb$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_6]][@a] = %[[VAL_0]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:        pod.write %[[VAL_5]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:        scf.if %[[VAL_11]] {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_12]], %[[VAL_13]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          pod.write %[[VAL_5]][@comp] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        pod.write %[[VAL_6]][@b] = %[[VAL_1]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:        pod.write %[[VAL_5]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:        scf.if %[[VAL_19]] {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_20]], %[[VAL_21]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          pod.write %[[VAL_5]][@comp] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_23]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@x] = %[[VAL_24]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_24]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@c] = %[[VAL_25]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@cb$inputs] = %[[VAL_6]] : <@A<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_3]][@cb] = %[[VAL_26]] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_27]][@c] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_27]][@x] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_27]][@cb] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_27]][@cb$inputs] : <@A<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_35]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_36]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_33]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_32]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_31]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @B::@constrain(%[[VAL_33]], %[[VAL_39]], %[[VAL_40]]) : (!struct.type<@B<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_41]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_43]][@c] = %[[VAL_44]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_43]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_45]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_46]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_48]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
