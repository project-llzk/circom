// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.2;

template OR() {
    signal input a;
}

template InvalidArgIndex(n, k) {
    component has_prev_non_zero[k * n];
    for (var i = k - 1; i >= 0; i--) {
        for (var j = n - 1; j >= 0; j--) {
            has_prev_non_zero[n * i + j] = OR();
            if (i == k - 1 && j == n - 1) {
                has_prev_non_zero[n * i + j].a <-- 99;
            } else {
                has_prev_non_zero[n * i + j].a <-- 33;
            }
        }
    }
}

component main = InvalidArgIndex(3, 2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InvalidArgIndex::@InvalidArgIndex<[3, 2]>>} {
// CHECK-NEXT:    poly.template @InvalidArgIndex {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.param @k
// CHECK-NEXT:      poly.expr @"k_Mul_n@338" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @InvalidArgIndex {
// CHECK-NEXT:        struct.member @has_prev_non_zero : !array.type<@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:        struct.member @has_prev_non_zero$inputs : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_4]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_13]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_6]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_24]]) %[[VAL_21]], %[[VAL_22]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_28]], @params = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_7]]{{\[}}%[[VAL_32]]] = %[[VAL_29]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_4]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_17]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_6]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_26]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_35]], %[[VAL_38]] : i1, i1
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_39]] -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_44]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_45]][@a] = %[[VAL_41]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_25]]{{\[}}%[[VAL_48]]] = %[[VAL_45]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_49]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_51]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:                pod.write %[[VAL_52]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:                scf.if %[[VAL_57]] {
// CHECK-NEXT:                  %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_59]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_52]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_7]]{{\[}}%[[VAL_63]]] = %[[VAL_52]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_25]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_65]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_67]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_68]][@a] = %[[VAL_64]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_25]]{{\[}}%[[VAL_71]]] = %[[VAL_68]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_74]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_76]], %[[VAL_77]] : index
// CHECK-NEXT:                pod.write %[[VAL_75]][@count] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_78]], %[[VAL_79]] : index
// CHECK-NEXT:                scf.if %[[VAL_80]] {
// CHECK-NEXT:                  %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_83:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_82]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_75]][@comp] = %[[VAL_83]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_7]]{{\[}}%[[VAL_86]]] = %[[VAL_75]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_25]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_40]], %[[VAL_88]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_17]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_20]]#0, %[[VAL_90]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@has_prev_non_zero$inputs] = %[[VAL_11]]#0 : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_94]] to %[[VAL_93]] step %[[VAL_95]] {
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_96]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            array.write %[[VAL_91]]{{\[}}%[[VAL_96]]] = %[[VAL_98]] : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@has_prev_non_zero] = %[[VAL_91]] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@has_prev_non_zero] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@has_prev_non_zero$inputs] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_108]], %[[VAL_109]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_110]]) %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_102]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_115:[0-9a-zA-Z_\.]+]] = %[[VAL_113]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_115]], %[[VAL_116]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_117]]) %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_118:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_120]], @params = %[[VAL_119]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_111]], %[[VAL_123]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_102]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_118]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_124]], %[[VAL_127]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_128]] {
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_118]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_111]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_135]] to %[[VAL_134]] step %[[VAL_136]] {
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_137]]] : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_137]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @OR::@OR::@constrain(%[[VAL_138]], %[[VAL_140]]) : (!struct.type<@OR::@OR<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @OR {
// CHECK-NEXT:      struct.def @OR {
// CHECK-NEXT:        function.def @compute(%[[VAL_141:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = struct.new : <@OR::@OR<[]>>
// CHECK-NEXT:          function.return %[[VAL_142]] : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_143:[0-9a-zA-Z_\.]+]]: !struct.type<@OR::@OR<[]>>, %[[VAL_144:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
