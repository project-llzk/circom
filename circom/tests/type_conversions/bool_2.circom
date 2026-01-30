// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function binop_bool(a, b) {
  return a || b;
}

template A(x) {
  signal input in;
  signal output out;

  var temp;
  if (binop_bool(in, x)) {
    temp = 1;
  } else {
    temp = 0;
  }
  // Cannot use `<==` here because it creates a non quadratic constraint
  // due to `||` in the function.
  out <-- temp;

  //Essentially equivalent code:
  // out <-- binop_bool(in, x);
}

component main = A(555);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[555]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @binop_bool(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_1]], %[[VAL_4]])
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_3]], %[[VAL_5]] : i1, i1
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : i1
// CHECK-NEXT:      function.return %[[VAL_7]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @A<[@x]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@x]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @binop_bool(%[[VAL_8]], %[[VAL_10]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_12]], %[[VAL_13]])
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_14]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_17]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_9]][@out] = %[[VAL_15]] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_9]] : !struct.type<@A<[@x]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@x]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_UNUSED:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@out] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @binop_bool(%[[VAL_19]], %[[VAL_20]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_22]], %[[VAL_23]])
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_26]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_27]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
