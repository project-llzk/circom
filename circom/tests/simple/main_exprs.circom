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
// CHECK-NEXT:      poly.param @a : index
// CHECK-NEXT:      poly.param @b : index
// CHECK-NEXT:      poly.param @c : index
// CHECK-NEXT:      poly.param @d : index
// CHECK-NEXT:      poly.param @e : index
// CHECK-NEXT:      poly.param @f : index
// CHECK-NEXT:      poly.param @g : index
// CHECK-NEXT:      poly.param @h : index
// CHECK-NEXT:      poly.param @i : index
// CHECK-NEXT:      poly.param @j : index
// CHECK-NEXT:      poly.param @k : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @c : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_5]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @d : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @e : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @f : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @g : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_13]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @h : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_15]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @i : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_17]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @k : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_21]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_24]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_26]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @c : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_28]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @d : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_30]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.read_const @e : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_32]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @f : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_34]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.read_const @g : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_36]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @h : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_38]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @i : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_40]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_42]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @k : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_44]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
