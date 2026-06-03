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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @cb : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @cb$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a", llzk.pub}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b", llzk.pub}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "d"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_7]][@a] = %[[VAL_0]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_11]], %[[VAL_12]] : index
// CHECK-NEXT:          pod.write %[[VAL_10]][@count] = %[[VAL_13]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:          scf.if %[[VAL_15]] {
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_17]], %[[VAL_18]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_10]][@comp] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_7]][@b] = %[[VAL_1]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_20]], %[[VAL_21]] : index
// CHECK-NEXT:          pod.write %[[VAL_10]][@count] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:          scf.if %[[VAL_24]] {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_26]], %[[VAL_27]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_10]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x] = %[[VAL_30]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_30]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@c] = %[[VAL_31]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@cb$inputs] = %[[VAL_7]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_3]][@cb] = %[[VAL_32]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a", llzk.pub}, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b", llzk.pub}, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "d"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@c] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@x] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@cb] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@cb$inputs] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_39]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_38]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_38]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_39]], %[[VAL_47]], %[[VAL_48]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a", llzk.pub}, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b", llzk.pub}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_51]][@c] = %[[VAL_52]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_51]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a", llzk.pub}, %[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b", llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@c] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
