// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output x;

    x <== a * b;
}

template Call1() {
    signal input m;
    signal input n;
    signal output y;

    component a = B();
    a.a <== m;
    a.b <== n;
    // Call to B::compute should happen here
    y <== a.x;
}

component main = Call1();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Call1::@Call1<[]>>} {
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@x] = %[[VAL_3]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@x] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Call1 {
// CHECK-NEXT:      struct.def @Call1 {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Call1::@Call1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.new : <@Call1::@Call1<[]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]], @params = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_12]][@a] = %[[VAL_9]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          pod.write %[[VAL_15]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:          scf.if %[[VAL_20]] {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_22]], %[[VAL_23]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_15]][@comp] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_12]][@b] = %[[VAL_10]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:          pod.write %[[VAL_15]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          scf.if %[[VAL_29]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_31]], %[[VAL_32]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_15]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@x] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_11]][@y] = %[[VAL_35]] : <@Call1::@Call1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_11]][@a$inputs] = %[[VAL_12]] : <@Call1::@Call1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_11]][@a] = %[[VAL_36]] : <@Call1::@Call1<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_11]] : !struct.type<@Call1::@Call1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !struct.type<@Call1::@Call1<[]>>, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@y] : <@Call1::@Call1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@a] : <@Call1::@Call1<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@a$inputs] : <@Call1::@Call1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_44]], @params = %[[VAL_43]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@x] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_41]], %[[VAL_49]], %[[VAL_50]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
