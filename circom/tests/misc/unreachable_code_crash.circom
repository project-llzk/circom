// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.expr @"k_Mul_n@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_3]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @InvalidArgIndex {
// CHECK-NEXT:        struct.member @has_prev_non_zero : !array.type<@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:        struct.member @has_prev_non_zero$inputs : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]] to %[[VAL_11]] step %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_15]], @params = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_14]]] = %[[VAL_16]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_5]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_23]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_21]], %[[VAL_22]], %[[VAL_23]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_26]], %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_27]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_36]]) %[[VAL_32]], %[[VAL_33]], %[[VAL_34]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_41]], @params = %[[VAL_40]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_37]]{{\[}}%[[VAL_45]]] = %[[VAL_42]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_5]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_28]], %[[VAL_47]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_39]], %[[VAL_50]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_48]], %[[VAL_51]] : i1, i1
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_52]] -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_57]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_58]][@a] = %[[VAL_54]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_38]]{{\[}}%[[VAL_61]]] = %[[VAL_58]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_64]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_68]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_70]], %[[VAL_71]] : index
// CHECK-NEXT:                pod.write %[[VAL_65]][@count] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_72]], %[[VAL_73]] : index
// CHECK-NEXT:                scf.if %[[VAL_74]] {
// CHECK-NEXT:                  %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_77:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_76]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_65]][@comp] = %[[VAL_77]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_80]]] = %[[VAL_65]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_37]], %[[VAL_38]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_84]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_85]][@a] = %[[VAL_81]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_38]]{{\[}}%[[VAL_88]]] = %[[VAL_85]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_91]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_93]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_95]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_97]], %[[VAL_98]] : index
// CHECK-NEXT:                pod.write %[[VAL_92]][@count] = %[[VAL_99]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_99]], %[[VAL_100]] : index
// CHECK-NEXT:                scf.if %[[VAL_101]] {
// CHECK-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_104:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_103]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_92]][@comp] = %[[VAL_104]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_105]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_107]]] = %[[VAL_92]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_37]], %[[VAL_38]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_53]]#0, %[[VAL_53]]#1, %[[VAL_109]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_28]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]]#0, %[[VAL_31]]#1, %[[VAL_111]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@has_prev_non_zero$inputs] = %[[VAL_20]]#1 : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_116:[0-9a-zA-Z_\.]+]] = %[[VAL_114]] to %[[VAL_113]] step %[[VAL_115]] {
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]#0{{\[}}%[[VAL_116]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            array.write %[[VAL_112]]{{\[}}%[[VAL_116]]] = %[[VAL_118]] : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@has_prev_non_zero] = %[[VAL_112]] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_121]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@has_prev_non_zero] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@has_prev_non_zero$inputs] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_120]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_129]], %[[VAL_130]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_131]]) %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_132:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_123]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_134]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_136]], %[[VAL_137]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_138]]) %[[VAL_136]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_120]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_132]], %[[VAL_143]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_123]], %[[VAL_145]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_139]], %[[VAL_146]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_144]], %[[VAL_147]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_148]] {
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_139]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_132]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_154]] to %[[VAL_153]] step %[[VAL_155]] {
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_156]]] : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_125]]{{\[}}%[[VAL_156]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @OR::@OR::@constrain(%[[VAL_157]], %[[VAL_159]]) : (!struct.type<@OR::@OR<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @OR {
// CHECK-NEXT:      struct.def @OR {
// CHECK-NEXT:        function.def @compute(%[[VAL_160:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) -> !struct.type<@OR::@OR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = struct.new : <@OR::@OR<[]>>
// CHECK-NEXT:          function.return %[[VAL_161]] : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_162:[0-9a-zA-Z_\.]+]]: !struct.type<@OR::@OR<[]>>, %[[VAL_163:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
