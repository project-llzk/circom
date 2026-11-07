// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.2.0;

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}

template IsEqual() {
    signal input in[2];
    signal output out;

    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    isz.out ==> out;
}

bus PointN(dim){
    signal x[dim];
}

bus Line(dim){
    PointN(dim) start;
    PointN(dim) end;
}

bus Figure(num_sides, dim){
    Line(dim) side[num_sides];
}

bus Triangle2D(){
    Figure(3,2) {well_defined} triangle;
}

bus Square3D(){
    Figure(4,3) {well_defined} square;
}

template well_defined_figure(num_sides, dimension){
    input Figure(num_sides,dimension) t;
    output Figure(num_sides,dimension) {well_defined} correct_t;
    var all_equals = 0;
    var isequal = 0;
    for(var i = 0; i < num_sides; i=i+1){
        for(var j = 0; j < dimension; j=j+1){
            isequal = IsEqual()([t.side[i].end.x[j],t.side[(i+1)%num_sides].start.x[j]]);
            all_equals += isequal;
        }
    }
    all_equals === num_sides;
    correct_t <== t;
}

component main = well_defined_figure(3,2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@well_defined_figure::@"$bus_entry"<[3, 2]>>} {
// CHECK-NEXT:    poly.template @IsEqual {
// CHECK-NEXT:      struct.def @IsEqual {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @isz : !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:        struct.member @isz$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@IsEqual::@IsEqual<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_7]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_8]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_12]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:          pod.write %[[VAL_5]][@count] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:          scf.if %[[VAL_17]] {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_.-]+]] = function.call @IsZero::@IsZero::@compute(%[[VAL_19]]) : (!felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            pod.write %[[VAL_5]][@comp] = %[[VAL_20]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_21]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_22]] : <@IsEqual::@IsEqual<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@isz$inputs] = %[[VAL_2]] : <@IsEqual::@IsEqual<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@isz] = %[[VAL_23]] : <@IsEqual::@IsEqual<[]>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_.-]+]]: !struct.type<@IsEqual::@IsEqual<[]>>, %[[VAL_25:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_24]][@out] : <@IsEqual::@IsEqual<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_24]][@isz] : <@IsEqual::@IsEqual<[]>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_24]][@isz$inputs] : <@IsEqual::@IsEqual<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_30]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_33]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_31]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_28]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_36]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_27]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_28]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @IsZero::@IsZero::@constrain(%[[VAL_27]], %[[VAL_38]]) : (!struct.type<@IsZero::@IsZero<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @IsZero {
// CHECK-NEXT:      struct.def @IsZero {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @inv : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_39:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@IsZero::@IsZero<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = struct.new : <@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_39]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_42]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_.-]+]] = felt.div %[[VAL_44]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_40]][@inv] = %[[VAL_43]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = felt.neg %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.mul %[[VAL_47]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_48]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_40]][@out] = %[[VAL_50]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_51:[0-9a-zA-Z_.-]+]]: !struct.type<@IsZero::@IsZero<[]>>, %[[VAL_52:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_51]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_51]][@inv] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = felt.neg %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = felt.mul %[[VAL_55]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_56]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = felt.mul %[[VAL_52]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_59]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @well_defined_figure {
// CHECK-NEXT:      poly.param @num_sides : index
// CHECK-NEXT:      poly.param @dimension : index
// CHECK-NEXT:      poly.expr @"anon_var_[[MEMBER0:[0-9]+_[0-9]+]]@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_.-]+]] = poly.read_const @dimension : index
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_61]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_63]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_.-]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_66]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @well_defined_figure {
// CHECK-NEXT:        struct.member @correct_t : !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @IsEqual_[[MEMBER1:[0-9]+_[0-9]+]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>
// CHECK-NEXT:        struct.member @IsEqual_[[MEMBER1]]$inputs : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_67:[0-9a-zA-Z_.-]+]]: !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]> {function.arg_name = "t"}) -> !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = struct.new : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_69]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = poly.read_const @dimension : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_71]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_73]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_80:[0-9a-zA-Z_.-]+]] = %[[VAL_78]] to %[[VAL_77]] step %[[VAL_79]] {
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_81]], @params = %[[VAL_76]] }  : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_75]]{{\[}}%[[VAL_80]]] = %[[VAL_82]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]]:7 = scf.while (%[[VAL_90:[0-9a-zA-Z_.-]+]] = %[[VAL_75]], %[[VAL_91:[0-9a-zA-Z_.-]+]] = %[[VAL_83]], %[[VAL_92:[0-9a-zA-Z_.-]+]] = %[[VAL_86]], %[[VAL_93:[0-9a-zA-Z_.-]+]] = %[[VAL_85]], %[[VAL_94:[0-9a-zA-Z_.-]+]] = %[[VAL_84]], %[[VAL_95:[0-9a-zA-Z_.-]+]] = %[[VAL_88]], %[[VAL_96:[0-9a-zA-Z_.-]+]] = %[[VAL_87]]) : (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_95]], %[[VAL_74]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_97]]) %[[VAL_90]], %[[VAL_91]], %[[VAL_92]], %[[VAL_93]], %[[VAL_94]], %[[VAL_95]], %[[VAL_96]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_98:[0-9a-zA-Z_.-]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, %[[VAL_99:[0-9a-zA-Z_.-]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_100:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_101:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_102:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_103:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_104:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]]:6 = scf.while (%[[VAL_107:[0-9a-zA-Z_.-]+]] = %[[VAL_98]], %[[VAL_108:[0-9a-zA-Z_.-]+]] = %[[VAL_99]], %[[VAL_109:[0-9a-zA-Z_.-]+]] = %[[VAL_100]], %[[VAL_110:[0-9a-zA-Z_.-]+]] = %[[VAL_102]], %[[VAL_111:[0-9a-zA-Z_.-]+]] = %[[VAL_104]], %[[VAL_112:[0-9a-zA-Z_.-]+]] = %[[VAL_105]]) : (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_112]], %[[VAL_72]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_113]]) %[[VAL_107]], %[[VAL_108]], %[[VAL_109]], %[[VAL_110]], %[[VAL_111]], %[[VAL_112]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_114:[0-9a-zA-Z_.-]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, %[[VAL_115:[0-9a-zA-Z_.-]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_116:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_117:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_118:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_119:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_121]], @params = %[[VAL_120]] }  : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_114]]{{\[}}%[[VAL_123]]] = %[[VAL_122]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_67]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_125]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_126]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_127]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_129]]] : <@dimension x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_67]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_103]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_.-]+]] = felt.umod %[[VAL_133]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_135]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_136]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_137]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_139]]] : <@dimension x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_.-]+]] = array.new %[[VAL_130]], %[[VAL_140]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_142]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_143]][@in] = %[[VAL_141]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_144:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_115]]{{\[}}%[[VAL_144]]] = %[[VAL_143]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_145:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_146:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_145]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_148:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_147]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_146]][@count] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CHECK-NEXT:              %[[VAL_151:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_149]], %[[VAL_150]] : index
// CHECK-NEXT:              pod.write %[[VAL_146]][@count] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_152:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_151]], %[[VAL_152]] : index
// CHECK-NEXT:              scf.if %[[VAL_153]] {
// CHECK-NEXT:                %[[VAL_154:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_146]][@params] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_155:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_148]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_156:[0-9a-zA-Z_.-]+]] = function.call @IsEqual::@IsEqual::@compute(%[[VAL_155]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:                pod.write %[[VAL_146]][@comp] = %[[VAL_156]] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_114]]{{\[}}%[[VAL_157]]] = %[[VAL_146]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_158]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@comp] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_160]][@out] : <@IsEqual::@IsEqual<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_116]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_164:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_119]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_117]], %[[VAL_165]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_114]], %[[VAL_115]], %[[VAL_162]], %[[VAL_166]], %[[VAL_161]], %[[VAL_164]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_103]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_101]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_106]]#0, %[[VAL_106]]#1, %[[VAL_106]]#2, %[[VAL_170]], %[[VAL_106]]#3, %[[VAL_168]], %[[VAL_106]]#4 : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_68]][@correct_t] = %[[VAL_67]] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_68]][@IsEqual_[[MEMBER1]]$inputs] = %[[VAL_89]]#1 : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_175:[0-9a-zA-Z_.-]+]] = %[[VAL_173]] to %[[VAL_172]] step %[[VAL_174]] {
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_89]]#0{{\[}}%[[VAL_175]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_176]][@comp] : <[@count: index, @comp: !struct.type<@IsEqual::@IsEqual<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_175]]] = %[[VAL_177]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_68]][@IsEqual_[[MEMBER1]]] = %[[VAL_171]] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>
// CHECK-NEXT:          function.return %[[VAL_68]] : !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_178:[0-9a-zA-Z_.-]+]]: !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, %[[VAL_179:[0-9a-zA-Z_.-]+]]: !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]> {function.arg_name = "t"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_180]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = poly.read_const @dimension : index
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_182]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_184]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_178]][@correct_t] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_178]][@IsEqual_[[MEMBER1]]] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_178]][@IsEqual_[[MEMBER1]]$inputs] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]]:5 = scf.while (%[[VAL_195:[0-9a-zA-Z_.-]+]] = %[[VAL_191]], %[[VAL_196:[0-9a-zA-Z_.-]+]] = %[[VAL_190]], %[[VAL_197:[0-9a-zA-Z_.-]+]] = %[[VAL_189]], %[[VAL_198:[0-9a-zA-Z_.-]+]] = %[[VAL_193]], %[[VAL_199:[0-9a-zA-Z_.-]+]] = %[[VAL_192]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_198]], %[[VAL_185]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_200]]) %[[VAL_195]], %[[VAL_196]], %[[VAL_197]], %[[VAL_198]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_201:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_202:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_203:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_204:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_205:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_.-]+]]:4 = scf.while (%[[VAL_208:[0-9a-zA-Z_.-]+]] = %[[VAL_201]], %[[VAL_209:[0-9a-zA-Z_.-]+]] = %[[VAL_203]], %[[VAL_210:[0-9a-zA-Z_.-]+]] = %[[VAL_205]], %[[VAL_211:[0-9a-zA-Z_.-]+]] = %[[VAL_206]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_211]], %[[VAL_183]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_212]]) %[[VAL_208]], %[[VAL_209]], %[[VAL_210]], %[[VAL_211]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_213:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_214:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_215:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">, %[[VAL_216:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_179]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_218]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_219]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_220]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_216]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_221]]{{\[}}%[[VAL_222]]] : <@dimension x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_179]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_204]], %[[VAL_225]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_.-]+]] = felt.umod %[[VAL_226]], %[[VAL_185]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_224]]{{\[}}%[[VAL_228]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_229]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_230]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_216]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_231]]{{\[}}%[[VAL_232]]] : <@dimension x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_.-]+]] = array.new %[[VAL_223]], %[[VAL_233]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_235]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_236]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              constrain.eq %[[VAL_237]], %[[VAL_234]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_187]]{{\[}}%[[VAL_238]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_239]][@out] : <@IsEqual::@IsEqual<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_213]], %[[VAL_240]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_216]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_214]], %[[VAL_244]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_241]], %[[VAL_245]], %[[VAL_240]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_204]], %[[VAL_246]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_202]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_207]]#0, %[[VAL_249]], %[[VAL_207]]#1, %[[VAL_247]], %[[VAL_207]]#2 : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_194]]#0, %[[VAL_185]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_186]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_179]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_255:[0-9a-zA-Z_.-]+]] = %[[VAL_253]] to %[[VAL_252]] step %[[VAL_254]] {
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_250]]{{\[}}%[[VAL_255]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_251]]{{\[}}%[[VAL_255]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_256]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_257]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_260:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_258]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_259]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_260]], %[[VAL_261]] : !array.type<@dimension x !felt.type<"bn128">>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_256]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_257]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_264:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_262]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_265:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_263]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_264]], %[[VAL_265]] : !array.type<@dimension x !felt.type<"bn128">>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_269:[0-9a-zA-Z_.-]+]] = %[[VAL_267]] to %[[VAL_266]] step %[[VAL_268]] {
// CHECK-NEXT:            %[[VAL_270:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_187]]{{\[}}%[[VAL_269]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@IsEqual::@IsEqual<[]>>>, !struct.type<@IsEqual::@IsEqual<[]>>
// CHECK-NEXT:            %[[VAL_271:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_269]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_272:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_271]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @IsEqual::@IsEqual::@constrain(%[[VAL_270]], %[[VAL_272]]) : (!struct.type<@IsEqual::@IsEqual<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @"$bus_entry" {
// CHECK-NEXT:        struct.member @"$component" : !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:        struct.member @correct_t.side.start.x : !array.type<@num_sides,@dimension x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @correct_t.side.end.x : !array.type<@num_sides,@dimension x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_273:[0-9a-zA-Z_.-]+]]: !array.type<@num_sides,@dimension x !felt.type<"bn128">> {function.arg_name = "t.side.start.x"}, %[[VAL_274:[0-9a-zA-Z_.-]+]]: !array.type<@num_sides,@dimension x !felt.type<"bn128">> {function.arg_name = "t.side.end.x"}) -> !struct.type<@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = struct.new : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_276]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = poly.read_const @dimension : index
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_278]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_280]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = array.new  : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_286:[0-9a-zA-Z_.-]+]] = %[[VAL_284]] to %[[VAL_283]] step %[[VAL_285]] {
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_273]]{{\[}}%[[VAL_286]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_287]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_274]]{{\[}}%[[VAL_286]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_289]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_.-]+]] = pod.new { @start = %[[VAL_288]], @end = %[[VAL_290]] }  : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            array.write %[[VAL_282]]{{\[}}%[[VAL_286]]] = %[[VAL_291]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = pod.new { @side = %[[VAL_282]] }  : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_293:[0-9a-zA-Z_.-]+]] = function.call @well_defined_figure::@well_defined_figure::@compute(%[[VAL_292]]) : (!pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>) -> !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:          struct.writem %[[VAL_275]][@"$component"] = %[[VAL_293]] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:          %[[VAL_294:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_295:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_296:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_293]][@correct_t] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_297:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_296]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_298:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_299:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_300:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_301:[0-9a-zA-Z_.-]+]] = %[[VAL_299]] to %[[VAL_298]] step %[[VAL_300]] {
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_301]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_302]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_303]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            array.insert %[[VAL_294]]{{\[}}%[[VAL_301]]] = %[[VAL_304]] : <@num_sides,@dimension x !felt.type<"bn128">>, <@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_302]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_306:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_305]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            array.insert %[[VAL_295]]{{\[}}%[[VAL_301]]] = %[[VAL_306]] : <@num_sides,@dimension x !felt.type<"bn128">>, <@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_275]][@correct_t.side.start.x] = %[[VAL_294]] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_275]][@correct_t.side.end.x] = %[[VAL_295]] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_275]] : !struct.type<@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_307:[0-9a-zA-Z_.-]+]]: !struct.type<@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, %[[VAL_308:[0-9a-zA-Z_.-]+]]: !array.type<@num_sides,@dimension x !felt.type<"bn128">> {function.arg_name = "t.side.start.x"}, %[[VAL_309:[0-9a-zA-Z_.-]+]]: !array.type<@num_sides,@dimension x !felt.type<"bn128">> {function.arg_name = "t.side.end.x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_310:[0-9a-zA-Z_.-]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_310]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_312:[0-9a-zA-Z_.-]+]] = poly.read_const @dimension : index
// CHECK-NEXT:          %[[VAL_313:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_312]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_314:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_315:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_314]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_316:[0-9a-zA-Z_.-]+]] = array.new  : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_318:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_320:[0-9a-zA-Z_.-]+]] = %[[VAL_318]] to %[[VAL_317]] step %[[VAL_319]] {
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_308]]{{\[}}%[[VAL_320]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_321]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_309]]{{\[}}%[[VAL_320]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_323]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_.-]+]] = pod.new { @start = %[[VAL_322]], @end = %[[VAL_324]] }  : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            array.write %[[VAL_316]]{{\[}}%[[VAL_320]]] = %[[VAL_325]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_.-]+]] = pod.new { @side = %[[VAL_316]] }  : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_307]][@"$component"] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>
// CHECK-NEXT:          function.call @well_defined_figure::@well_defined_figure::@constrain(%[[VAL_327]], %[[VAL_326]]) : (!struct.type<@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>) -> ()
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_307]][@correct_t.side.start.x] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_329:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_307]][@correct_t.side.end.x] : <@well_defined_figure::@"$bus_entry"<[@num_sides, @dimension]>>, !array.type<@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_327]][@correct_t] : <@well_defined_figure::@well_defined_figure<[@num_sides, @dimension]>>, !pod.type<[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_.-]+]] = array.new  : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_332:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_333:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_334:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_335:[0-9a-zA-Z_.-]+]] = %[[VAL_333]] to %[[VAL_332]] step %[[VAL_334]] {
// CHECK-NEXT:            %[[VAL_336:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_328]]{{\[}}%[[VAL_335]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_336]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_338:[0-9a-zA-Z_.-]+]] = array.extract %[[VAL_329]]{{\[}}%[[VAL_335]]] : <@num_sides,@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_339:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_338]] }  : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_340:[0-9a-zA-Z_.-]+]] = pod.new { @start = %[[VAL_337]], @end = %[[VAL_339]] }  : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            array.write %[[VAL_331]]{{\[}}%[[VAL_335]]] = %[[VAL_340]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_.-]+]] = pod.new { @side = %[[VAL_331]] }  : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>
// CHECK-NEXT:          %[[VAL_342:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_330]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_343:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_341]][@side] : <[@side: !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>]>, !array.type<@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>
// CHECK-NEXT:          %[[VAL_344:[0-9a-zA-Z_.-]+]] = poly.read_const @num_sides : index
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_347:[0-9a-zA-Z_.-]+]] = %[[VAL_345]] to %[[VAL_344]] step %[[VAL_346]] {
// CHECK-NEXT:            %[[VAL_348:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_342]]{{\[}}%[[VAL_347]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            %[[VAL_349:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_343]]{{\[}}%[[VAL_347]]] : <@num_sides x !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>>, !pod.type<[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            %[[VAL_350:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_348]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_351:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_349]][@start] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_350]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_353:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_351]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_352]], %[[VAL_353]] : !array.type<@dimension x !felt.type<"bn128">>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_354:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_348]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_349]][@end] : <[@start: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>, @end: !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@dimension x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_354]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_357:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_355]][@x] : <[@x: !array.type<@dimension x !felt.type<"bn128">>]>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_356]], %[[VAL_357]] : !array.type<@dimension x !felt.type<"bn128">>, !array.type<@dimension x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
