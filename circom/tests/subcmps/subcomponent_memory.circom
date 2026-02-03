// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
  signal input x;
  signal input y[10];
}

template C() {
  signal input f;
}

template A() {
  component b = B();
  component c[2][1];
  c[0][0] = C();
  c[1][0] = C();
}

component main = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-DAG:       struct.field @c : !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:       struct.field @c$inputs : !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:       struct.field @b : !struct.type<@B<[]>>
// CHECK-DAG:       struct.field @b$inputs : !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-DAG:         %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>
// CHECK-DAG:         %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK-DAG:           scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_3]] to %[[VAL_6]] step %[[VAL_4]] {
// CHECK-DAG:             %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_7]], %[[VAL_8]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:             pod.write %[[VAL_9]][@count] = %[[VAL_1]] : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:             array.write %[[VAL_2]]{{\[}}%[[VAL_7]], %[[VAL_8]]] = %[[VAL_9]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:           }
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:         %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-DAG:         %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-DAG:         %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-DAG:         array.write %[[VAL_2]]{{\[}}%[[VAL_17]], %[[VAL_19]]] = %[[VAL_15]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-DAG:         %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]]
// CHECK-DAG:         array.write %[[VAL_2]]{{\[}}%[[VAL_23]], %[[VAL_25]]] = %[[VAL_21]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         struct.writef %[[VAL_0]][@c$inputs] = %[[VAL_10]] : <@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:         %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:         %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         scf.for %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_27]] to %[[VAL_29]] step %[[VAL_28]] {
// CHECK-DAG:           scf.for %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_27]] to %[[VAL_30]] step %[[VAL_28]] {
// CHECK-DAG:             %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_31]], %[[VAL_32]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:             %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@comp] : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C<[]>>
// CHECK-DAG:             array.write %[[VAL_26]]{{\[}}%[[VAL_31]], %[[VAL_32]]] = %[[VAL_34]] : <2,1 x !struct.type<@C<[]>>>, !struct.type<@C<[]>>
// CHECK-DAG:           }
// CHECK-DAG:         }
// CHECK-DAG:         struct.writef %[[VAL_0]][@c] = %[[VAL_26]] : <@A<[]>>, !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:         struct.writef %[[VAL_0]][@b$inputs] = %[[VAL_13]] : <@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-DAG:         struct.writef %[[VAL_0]][@b] = %[[VAL_35]] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_36]][@c] : <@A<[]>>, !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:         %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_36]][@c$inputs] : <@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:         %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_36]][@b] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-DAG:         %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_36]][@b$inputs] : <@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_43]] }  : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         scf.for %[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_45]] to %[[VAL_47]] step %[[VAL_46]] {
// CHECK-DAG:           scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_45]] to %[[VAL_48]] step %[[VAL_46]] {
// CHECK-DAG:             %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_49]], %[[VAL_50]]] : <2,1 x !struct.type<@C<[]>>>, !struct.type<@C<[]>>
// CHECK-DAG:             %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_49]], %[[VAL_50]]] : <2,1 x !pod.type<[@f: !felt.type]>>, !pod.type<[@f: !felt.type]>
// CHECK-DAG:             %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@f] : <[@f: !felt.type]>, !felt.type
// CHECK-DAG:             function.call @C::@constrain(%[[VAL_51]], %[[VAL_53]]) : (!struct.type<@C<[]>>, !felt.type) -> ()
// CHECK-DAG:           }
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@x] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !felt.type
// CHECK-DAG:         %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@y] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-DAG:         function.call @B::@constrain(%[[VAL_39]], %[[VAL_54]], %[[VAL_55]]) : (!struct.type<@B<[]>>, !felt.type, !array.type<10 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_58]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @C<[]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.new : <@C<[]>>
// CHECK-NEXT:        function.return %[[VAL_63]] : !struct.type<@C<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@C<[]>>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
