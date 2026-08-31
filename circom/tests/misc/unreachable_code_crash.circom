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
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_9_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_9_IN]], %[[VAL_21]], %[[VAL_22]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_9_IN_2:[0-9a-zA-Z_\.]+]] = %[[VAL_9_LCV]], %[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_25]], %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_31]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_33]]) %[[VAL_9_IN_2]], %[[VAL_30]], %[[VAL_31]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_9_LCV_2:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_9_LCV_2]]{{\[}}%[[VAL_41]]] = %[[VAL_38]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_5]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_26]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_35]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_44]], %[[VAL_47]] : i1, i1
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_48]] -> (!array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_53]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_54]][@a] = %[[VAL_50]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_34]]{{\[}}%[[VAL_57]]] = %[[VAL_54]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9_LCV_2]]{{\[}}%[[VAL_60]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_64]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_66]], %[[VAL_67]] : index
// CHECK-NEXT:                pod.write %[[VAL_61]][@count] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_68]], %[[VAL_69]] : index
// CHECK-NEXT:                scf.if %[[VAL_70]] {
// CHECK-NEXT:                  %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_73:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_72]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_61]][@comp] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_9_LCV_2]]{{\[}}%[[VAL_76]]] = %[[VAL_61]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_9_LCV_2]], %[[VAL_34]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_80]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_81]][@a] = %[[VAL_77]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_34]]{{\[}}%[[VAL_84]]] = %[[VAL_81]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_85]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9_LCV_2]]{{\[}}%[[VAL_87]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_91]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@count] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_93]], %[[VAL_94]] : index
// CHECK-NEXT:                pod.write %[[VAL_88]][@count] = %[[VAL_95]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_95]], %[[VAL_96]] : index
// CHECK-NEXT:                scf.if %[[VAL_97]] {
// CHECK-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@params] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = function.call @OR::@OR::@compute(%[[VAL_99]]) : (!felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_88]][@comp] = %[[VAL_100]] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_9_LCV_2]]{{\[}}%[[VAL_103]]] = %[[VAL_88]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_9_LCV_2]], %[[VAL_34]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_49]]#0, %[[VAL_49]]#1, %[[VAL_105]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_29]]#0, %[[VAL_29]]#1, %[[VAL_107]] : !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@has_prev_non_zero$inputs] = %[[VAL_20]]#1 : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.new  : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_112:[0-9a-zA-Z_\.]+]] = %[[VAL_110]] to %[[VAL_109]] step %[[VAL_111]] {
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]#0{{\[}}%[[VAL_112]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            array.write %[[VAL_108]]{{\[}}%[[VAL_112]]] = %[[VAL_114]] : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@has_prev_non_zero] = %[[VAL_108]] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_115:[0-9a-zA-Z_\.]+]]: !struct.type<@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_117]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_115]][@has_prev_non_zero] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_115]][@has_prev_non_zero$inputs] : <@InvalidArgIndex::@InvalidArgIndex<[@n, @k]>>, !array.type<@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_116]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_125:[0-9a-zA-Z_\.]+]] = %[[VAL_123]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_125]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_127]]) %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_128:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_119]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_130]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_132]], %[[VAL_133]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_134]]) %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_135:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_116]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_128]], %[[VAL_139]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_119]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_135]], %[[VAL_142]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_140]], %[[VAL_143]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_144]] {
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_135]], %[[VAL_145]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_128]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = poly.read_const @"k_Mul_n@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_150]] to %[[VAL_149]] step %[[VAL_151]] {
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_152]]] : <@"k_Mul_n@[[OFFSET0]]" x !struct.type<@OR::@OR<[]>>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_152]]] : <@"k_Mul_n@[[OFFSET0]]" x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
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
