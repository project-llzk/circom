// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template CompConstant(ct) {
    signal input in;
    signal output out;

    out <== ct * in;
}

template Sign() {
    signal input in;
    signal output sign;

    component comp = CompConstant(10944121435919637611123202872628637544274182200208017171849102093287904247808);

    comp.in <== in;
    sign <== comp.out;
}



component main = Sign();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Sign::@Sign<[]>>} {
// CHECK-NEXT:    poly.template @CompConstant {
// CHECK-NEXT:      poly.param @ct : index
// CHECK-NEXT:      struct.def @CompConstant {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CompConstant::@CompConstant<[@ct]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CompConstant::@CompConstant<[@ct]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @ct : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_3]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CompConstant::@CompConstant<[@ct]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@CompConstant::@CompConstant<[@ct]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @ct : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@out] : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sign {
// CHECK-NEXT:      poly.expr @"10944121435919637611123202872628637544274182200208017171849102093287904247808@429" {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  10944121435919637611123202872628637544274182200208017171849102093287904247808 : <"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @Sign {
// CHECK-NEXT:        struct.member @sign : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @comp : !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:        struct.member @comp$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Sign::@Sign<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@Sign::@Sign<[]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@429" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@429" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @ct = %[[VAL_17]] }  : <[@ct: index]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]], @params = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_15]][@in] = %[[VAL_12]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@count] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:          pod.write %[[VAL_20]][@count] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// CHECK-NEXT:          scf.if %[[VAL_25]] {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@params] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, !pod.type<[@ct: index]>
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @CompConstant::@CompConstant::@compute(%[[VAL_27]]) : (!felt.type<"bn128">) -> !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:            pod.write %[[VAL_20]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@sign] = %[[VAL_30]] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp$inputs] = %[[VAL_15]] : <@Sign::@Sign<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp] = %[[VAL_31]] : <@Sign::@Sign<[]>>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@Sign::@Sign<[]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@429" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@sign] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@comp] : <@Sign::@Sign<[]>>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@comp$inputs] : <@Sign::@Sign<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@429" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @ct = %[[VAL_39]] }  : <[@ct: index]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, @params: !pod.type<[@ct: index]>]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_42]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@out] : <@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_35]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @CompConstant::@CompConstant::@constrain(%[[VAL_36]], %[[VAL_44]]) : (!struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@429"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
