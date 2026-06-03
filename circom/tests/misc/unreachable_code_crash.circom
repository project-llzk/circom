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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InvalidArgIndex::@InvalidArgIndex<[3, 2]>>} {
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
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]] to %[[VAL_10]] step %[[VAL_12]] {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_7]]{{\[}}%[[VAL_13]]] = %[[VAL_15]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_4]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_21]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_23]]) %[[VAL_20]], %[[VAL_21]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_6]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_24]], %[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]) : (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_30]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_32]]) %[[VAL_29]], %[[VAL_30]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_36]], @params = %[[VAL_35]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_7]]{{\[}}%[[VAL_40]]] = %[[VAL_37]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_4]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_25]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_6]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_34]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_43]], %[[VAL_46]] : i1, i1
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_47]] -> (!array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_52]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_53]][@a] = %[[VAL_49]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_54]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_33]]{{\[}}%[[VAL_56]]] = %[[VAL_53]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_59]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_63]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_65]], %[[VAL_66]] : index
// CHECK-NEXT:                pod.write %[[VAL_60]][@count] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:                scf.if %[[VAL_69]] {
// CHECK-NEXT:                  %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_71]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_60]][@comp] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_73]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_7]]{{\[}}%[[VAL_75]]] = %[[VAL_60]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_33]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_79]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_80]][@a] = %[[VAL_76]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_33]]{{\[}}%[[VAL_83]]] = %[[VAL_80]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_86]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_88]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_90]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_92]], %[[VAL_93]] : index
// CHECK-NEXT:                pod.write %[[VAL_87]][@count] = %[[VAL_94]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_95]] : index
// CHECK-NEXT:                scf.if %[[VAL_96]] {
// CHECK-NEXT:                  %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_98]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_87]][@comp] = %[[VAL_99]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_7]]{{\[}}%[[VAL_102]]] = %[[VAL_87]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_33]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_34]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_48]], %[[VAL_104]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_25]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]]#0, %[[VAL_106]] : !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@has_prev_non_zero$inputs] = %[[VAL_19]]#0 : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_112:[0-9a-zA-Z_\.]+]] = %[[VAL_110]] to %[[VAL_109]] step %[[VAL_111]] {
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_112]]] : <@"k_Mul_n@338" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            array.write %[[VAL_107]]{{\[}}%[[VAL_112]]] = %[[VAL_114]] : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@has_prev_non_zero] = %[[VAL_107]] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_115:[0-9a-zA-Z_\.]+]]: !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_115]][@has_prev_non_zero] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_115]][@has_prev_non_zero$inputs] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_116]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_124:[0-9a-zA-Z_\.]+]] = %[[VAL_122]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_124]], %[[VAL_125]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_126]]) %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_127:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_118]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_131:[0-9a-zA-Z_\.]+]] = %[[VAL_129]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_131]], %[[VAL_132]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_133]]) %[[VAL_131]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_134:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_116]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_127]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_118]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_134]], %[[VAL_141]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_139]], %[[VAL_142]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_143]] {
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_134]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_127]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@338" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_150]] to %[[VAL_149]] step %[[VAL_151]] {
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_152]]] : <@"k_Mul_n@338" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_152]]] : <@"k_Mul_n@338" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @OR::@OR::@constrain(%[[VAL_153]], %[[VAL_155]]) : (!struct.type<@OR::@OR<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @OR {
// CHECK-NEXT:      struct.def @OR {
// CHECK-NEXT:        function.def @compute(%[[VAL_156:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) -> !struct.type<@OR::@OR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = struct.new : <@OR::@OR<[]>>
// CHECK-NEXT:          function.return %[[VAL_157]] : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_158:[0-9a-zA-Z_\.]+]]: !struct.type<@OR::@OR<[]>>, %[[VAL_159:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
