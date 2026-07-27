// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a) {
    return a;
}

template Template(m, n, c) {
    var v[2][2] = m;
    var x[c] = n;
    var ret[2][2] = f(v);
}

component main = Template([[0, 1], [2, 3]], [1, 0], 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Template_0::@Template_0<[]>>} {
// CHECK-NEXT:    poly.template @f_0 {
// CHECK-NEXT:      function.def @f_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !array.type<2,2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return %[[VAL_0]] : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Template_0 {
// CHECK-NEXT:      struct.def @Template_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Template_0::@Template_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Template_0::@Template_0<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_15]]{{\[}}%[[VAL_24]]] = %[[VAL_16]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_15]]{{\[}}%[[VAL_26]]] = %[[VAL_16]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_27]]{{\[}}%[[VAL_30]]] = %[[VAL_28]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_27]]{{\[}}%[[VAL_33]]] = %[[VAL_31]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_35]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_35]]{{\[}}%[[VAL_41]]] = %[[VAL_39]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_43]]] = %[[VAL_35]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_45]]] = %[[VAL_35]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = function.call @f_0::@f_0(%[[VAL_9]]) : (!array.type<2,2 x !felt.type<"bn128">>) -> !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Template_0::@Template_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@Template_0::@Template_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_62]]{{\[}}%[[VAL_65]]] = %[[VAL_63]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_62]]{{\[}}%[[VAL_68]]] = %[[VAL_66]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_61]]{{\[}}%[[VAL_70]]] = %[[VAL_62]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_61]]{{\[}}%[[VAL_72]]] = %[[VAL_62]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_73]]{{\[}}%[[VAL_76]]] = %[[VAL_74]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_73]]{{\[}}%[[VAL_79]]] = %[[VAL_77]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_81]]{{\[}}%[[VAL_84]]] = %[[VAL_82]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_81]]{{\[}}%[[VAL_87]]] = %[[VAL_85]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_80]]{{\[}}%[[VAL_89]]] = %[[VAL_81]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_80]]{{\[}}%[[VAL_91]]] = %[[VAL_81]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = function.call @f_0::@f_0(%[[VAL_55]]) : (!array.type<2,2 x !felt.type<"bn128">>) -> !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [
// CHECK-SAME:      #felt<const 0 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 1 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 2 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 3 : <"bn128">> : !felt.type<"bn128">]
// CHECK-NEXT:    global.def const @vcp_array_const_1 : !array.type<2 x !felt.type<"bn128">> = [
// CHECK-SAME:      #felt<const 1 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 0 : <"bn128">> : !felt.type<"bn128">]
// CHECK-NEXT:  }
