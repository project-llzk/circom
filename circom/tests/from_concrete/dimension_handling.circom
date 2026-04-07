// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function myAdd(x1,y1,x2,y2) {
    var res[2] = [0x1 + y1, x2 + y2];
    return res;
}

function myFun() {
    var out[1][1];
    var dbl[2] = [18446744073709551557,18446744073709551557];
    for (var i=0; i < 4; i++) {
        dbl = myAdd(dbl[0], dbl[1], dbl[0], dbl[1]);
    }
    return out;
}

template A() {
    var table[1][1];
    table = myFun();
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A_0<[]>>} {
// CHECK-NEXT:    function.def @myAdd_1(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_3:[0-9a-zA-Z_\.]+]]: !felt.type) -> !array.type<2 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[V_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_6]]
// CHECK-NEXT:      array.write %[[V_4]]{{\[}}%[[V_7]]] = %[[V_5]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_9]]
// CHECK-NEXT:      array.write %[[V_4]]{{\[}}%[[V_10]]] = %[[V_8]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_12:[0-9a-zA-Z_\.]+]] = felt.add %[[V_11]], %[[V_1]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_13]]
// CHECK-NEXT:      array.write %[[V_4]]{{\[}}%[[V_14]]] = %[[V_12]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_15:[0-9a-zA-Z_\.]+]] = felt.add %[[V_2]], %[[V_3]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_16]]
// CHECK-NEXT:      array.write %[[V_4]]{{\[}}%[[V_17]]] = %[[V_15]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      function.return %[[V_4]] : !array.type<2 x !felt.type>
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @myFun_0() -> !array.type<1,1 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type>
// CHECK-NEXT:      %[[V_19:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type>
// CHECK-NEXT:      %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_21]]
// CHECK-NEXT:      array.write %[[V_19]]{{\[}}%[[V_22]]] = %[[V_20]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_23]]
// CHECK-NEXT:      array.insert %[[V_18]]{{\[}}%[[V_24]]] = %[[V_19]] : <1,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:      %[[V_25:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[V_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_27]]
// CHECK-NEXT:      array.write %[[V_25]]{{\[}}%[[V_28]]] = %[[V_26]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_30]]
// CHECK-NEXT:      array.write %[[V_25]]{{\[}}%[[V_31]]] = %[[V_29]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_32:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557
// CHECK-NEXT:      %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_33]]
// CHECK-NEXT:      array.write %[[V_25]]{{\[}}%[[V_34]]] = %[[V_32]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_35:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557
// CHECK-NEXT:      %[[V_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_36]]
// CHECK-NEXT:      array.write %[[V_25]]{{\[}}%[[V_37]]] = %[[V_35]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_39:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_40:[0-9a-zA-Z_\.]+]] = %[[V_25]], %[[V_41:[0-9a-zA-Z_\.]+]] = %[[V_38]]) : (!array.type<2 x !felt.type>, !felt.type) -> (!array.type<2 x !felt.type>, !felt.type) {
// CHECK-NEXT:        %[[V_42:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[V_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_41]], %[[V_42]])
// CHECK-NEXT:        scf.condition(%[[V_43]]) %[[V_40]], %[[V_41]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_44:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[V_45:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_46]]
// CHECK-NEXT:        %[[V_48:[0-9a-zA-Z_\.]+]] = array.read %[[V_44]]{{\[}}%[[V_47]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_49]]
// CHECK-NEXT:        %[[V_51:[0-9a-zA-Z_\.]+]] = array.read %[[V_44]]{{\[}}%[[V_50]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_52:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_52]]
// CHECK-NEXT:        %[[V_54:[0-9a-zA-Z_\.]+]] = array.read %[[V_44]]{{\[}}%[[V_53]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_55:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_55]]
// CHECK-NEXT:        %[[V_57:[0-9a-zA-Z_\.]+]] = array.read %[[V_44]]{{\[}}%[[V_56]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_58:[0-9a-zA-Z_\.]+]] = function.call @myAdd_1(%[[V_48]], %[[V_51]], %[[V_54]], %[[V_57]]) : (!felt.type, !felt.type, !felt.type, !felt.type) -> !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[V_59:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_60:[0-9a-zA-Z_\.]+]] = felt.add %[[V_45]], %[[V_59]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[V_58]], %[[V_60]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_18]] : !array.type<1,1 x !felt.type>
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @A_0<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_61:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0<[]>>
// CHECK-NEXT:        %[[V_62:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type>
// CHECK-NEXT:        %[[V_63:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[V_64:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_65]]
// CHECK-NEXT:        array.write %[[V_63]]{{\[}}%[[V_66]]] = %[[V_64]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_67:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_67]]
// CHECK-NEXT:        array.insert %[[V_62]]{{\[}}%[[V_68]]] = %[[V_63]] : <1,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[V_69:[0-9a-zA-Z_\.]+]] = function.call @myFun_0() : () -> !array.type<1,1 x !felt.type>
// CHECK-NEXT:        function.return %[[V_61]] : !struct.type<@A_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[V_70:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_71:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type>
// CHECK-NEXT:        %[[V_72:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[V_73:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_74]]
// CHECK-NEXT:        array.write %[[V_72]]{{\[}}%[[V_75]]] = %[[V_73]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_76:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_76]]
// CHECK-NEXT:        array.insert %[[V_71]]{{\[}}%[[V_77]]] = %[[V_72]] : <1,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[V_78:[0-9a-zA-Z_\.]+]] = function.call @myFun_0() : () -> !array.type<1,1 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
