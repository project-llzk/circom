// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal output x;
  x <== n;
}

template B() {
  component a[2];
  a[0] = A(1);
  a[1] = A(2);
}

component main = B();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_2::@B_2<[]>>} {
// CHECK-NEXT:    poly.template @A_0 {
// CHECK-NEXT:      struct.def @A_0 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@x] = %[[VAL_2]] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@x] : <@A_0::@A_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_1 {
// CHECK-NEXT:      struct.def @A_1 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_7]][@x] = %[[VAL_9]] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@x] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_2 {
// CHECK-NEXT:      struct.def @B_2 {
// CHECK-NEXT:        struct.member @a : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute() : () -> !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute() : () -> !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_18]], @idx_1 = %[[VAL_21]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_14]][@a$inputs] = %[[VAL_23]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_25]], @idx_1 = %[[VAL_27]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_14]][@a] = %[[VAL_28]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@a] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@a$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@idx_0] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_32]]) : (!struct.type<@A_0::@A_0<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@idx_1] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_34]]) : (!struct.type<@A_1::@A_1<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
