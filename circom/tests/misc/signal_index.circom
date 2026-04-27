// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
    signal output c;
    signal x;

    component cb = B();
    cb.a <== a;
    cb.b <== b;

    x <== cb.c;
    c <== x * 5;
}

component main {public [a, b]} = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @cb : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @cb$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_3]][@a] = %[[VAL_0]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          pod.write %[[VAL_6]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:          scf.if %[[VAL_11]] {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_13]], %[[VAL_14]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_6]][@comp] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_3]][@b] = %[[VAL_1]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          pod.write %[[VAL_6]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:          scf.if %[[VAL_20]] {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_22]], %[[VAL_23]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_6]][@comp] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@x] = %[[VAL_26]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_28]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@cb$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@cb] = %[[VAL_29]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@c] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@x] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@cb] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@cb$inputs] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_38]], @params = %[[VAL_37]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_34]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_34]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_33]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_35]], %[[VAL_45]], %[[VAL_46]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_47]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_49]][@c] = %[[VAL_50]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_49]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_52:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_52]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
