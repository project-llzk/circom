// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.2.0;

function f(x) {
    return x + 1;
}
template A(a,b,c,d,e,f,g,h,i,j,k) {}

component main = A( 3<<3, -12+24, 4*5, 20/4, 20\4, 7%3, 2^3, (1+2)*3, 6&2, 5!=2, !(1==1 ? 2<2 : 4*1^5&3) );

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[24, 12, 20, 5, 5, 1, 1, 9, 2, 1, 1]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @a
// CHECK-NEXT:      poly.param @b
// CHECK-NEXT:      poly.param @c
// CHECK-NEXT:      poly.param @d
// CHECK-NEXT:      poly.param @e
// CHECK-NEXT:      poly.param @f
// CHECK-NEXT:      poly.param @g
// CHECK-NEXT:      poly.param @h
// CHECK-NEXT:      poly.param @i
// CHECK-NEXT:      poly.param @j
// CHECK-NEXT:      poly.param @k
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @a : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @c : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @d : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @e : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @f : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @g : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @h : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @a : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @c : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @d : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @e : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @f : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @g : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @h : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
