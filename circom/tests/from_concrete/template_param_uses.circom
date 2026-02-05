// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Template_0<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @f_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type>) -> !array.type<2,2 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !array.type<2,2 x !felt.type>
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Template_0<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Template_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Template_0<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_4]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_7]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_9]]{{\[}}%[[VAL_10]]] = %[[VAL_5]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_9]]{{\[}}%[[VAL_11]]] = %[[VAL_8]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_12]], %[[VAL_13]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:        array.write %[[VAL_16]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:        array.write %[[VAL_16]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_24]]] = %[[VAL_16]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_26]]] = %[[VAL_16]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]]
// CHECK-NEXT:        array.write %[[VAL_27]]{{\[}}%[[VAL_30]]] = %[[VAL_28]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]]
// CHECK-NEXT:        array.write %[[VAL_27]]{{\[}}%[[VAL_33]]] = %[[VAL_31]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]]
// CHECK-NEXT:        array.write %[[VAL_35]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:        array.write %[[VAL_35]]{{\[}}%[[VAL_41]]] = %[[VAL_39]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]]
// CHECK-NEXT:        array.insert %[[VAL_34]]{{\[}}%[[VAL_43]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]]
// CHECK-NEXT:        array.insert %[[VAL_34]]{{\[}}%[[VAL_45]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = function.call @f_0(%[[VAL_9]]) : (!array.type<2,2 x !felt.type>) -> !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Template_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@Template_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_49]], %[[VAL_50]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_52]], %[[VAL_53]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_55]]{{\[}}%[[VAL_56]]] = %[[VAL_51]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_55]]{{\[}}%[[VAL_57]]] = %[[VAL_54]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_58]], %[[VAL_59]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]]
// CHECK-NEXT:        array.write %[[VAL_62]]{{\[}}%[[VAL_65]]] = %[[VAL_63]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]]
// CHECK-NEXT:        array.write %[[VAL_62]]{{\[}}%[[VAL_68]]] = %[[VAL_66]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:        array.insert %[[VAL_61]]{{\[}}%[[VAL_70]]] = %[[VAL_62]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:        array.insert %[[VAL_61]]{{\[}}%[[VAL_72]]] = %[[VAL_62]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]]
// CHECK-NEXT:        array.write %[[VAL_73]]{{\[}}%[[VAL_76]]] = %[[VAL_74]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]]
// CHECK-NEXT:        array.write %[[VAL_73]]{{\[}}%[[VAL_79]]] = %[[VAL_77]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]]
// CHECK-NEXT:        array.write %[[VAL_81]]{{\[}}%[[VAL_84]]] = %[[VAL_82]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]]
// CHECK-NEXT:        array.write %[[VAL_81]]{{\[}}%[[VAL_87]]] = %[[VAL_85]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]]
// CHECK-NEXT:        array.insert %[[VAL_80]]{{\[}}%[[VAL_89]]] = %[[VAL_81]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]]
// CHECK-NEXT:        array.insert %[[VAL_80]]{{\[}}%[[VAL_91]]] = %[[VAL_81]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_92:[0-9a-zA-Z_\.]+]] = function.call @f_0(%[[VAL_55]]) : (!array.type<2,2 x !felt.type>) -> !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
