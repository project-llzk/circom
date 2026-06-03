// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template C() {
  signal input in;
  signal output out;
  var x = 12;
  out <-- negative(in);
}

function negative(n){
  if (n < 0) {
    return 1;
  } else {
    return 0;
  }
}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@C_0::@C_0<[]>>} {
// CHECK-NEXT:    poly.template @negative_0 {
// CHECK-NEXT:      function.def @negative_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "n"}) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C_0 {
// CHECK-NEXT:      struct.def @C_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@C_0::@C_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@C_0::@C_0<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @negative_0::@negative_0(%[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_7]][@out] = %[[VAL_9]] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@C_0::@C_0<[]>>, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@out] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
