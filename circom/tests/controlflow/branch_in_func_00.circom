// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(n){
  var x; // default initialization to 0
  if (n < 0) {
    var y = 12;
    var x = 23;
  } else {
    var y = 67;
    var x = 74;
    var z = 73;
  }
  return x;
}

template C() {
  signal input in;
  signal output out;
  out <-- f(in);
}

component main = C();

//
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@C::@C<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_3]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        scf.if %[[VAL_4]] {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  23 : <"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  67 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  74 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  73 : <"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_10]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_11]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_12]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_14]] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
