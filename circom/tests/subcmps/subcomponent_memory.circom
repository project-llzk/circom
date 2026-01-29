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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:    struct.def @A<[]> {
// CHECK-DAG:       struct.field @c : !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:       struct.field @c$inputs : !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:       struct.field @b : !struct.type<@B<[]>>
// CHECK-DAG:       struct.field @b$inputs : !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-LABEL:      function.def @compute() -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_3]] to %[[VAL_6]] step %[[VAL_4]] {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_7]], %[[VAL_8]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            pod.write %[[VAL_9]][@count] = %[[VAL_1]] : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_7]], %[[VAL_8]]] = %[[VAL_9]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         struct.writef %[[VAL_0]][@c$inputs] = %[[VAL_10]] : <@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-DAG:         %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:         %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         scf.for %[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_15]] to %[[VAL_17]] step %[[VAL_16]] {
// CHECK-DAG:           scf.for %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_15]] to %[[VAL_18]] step %[[VAL_16]] {
// CHECK-DAG:             %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_19]], %[[VAL_20]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:             %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C<[]>>
// CHECK-DAG:             array.write %[[VAL_14]]{{\[}}%[[VAL_19]], %[[VAL_20]]] = %[[VAL_22]] : <2,1 x !struct.type<@C<[]>>>, !struct.type<@C<[]>>
// CHECK-DAG:           }
// CHECK-DAG:         }
// CHECK-DAG:         struct.writef %[[VAL_0]][@c] = %[[VAL_14]] : <@A<[]>>, !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-DAG:         struct.writef %[[VAL_0]][@b$inputs] = %[[VAL_13]] : <@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-DAG:         struct.writef %[[VAL_0]][@b] = %[[VAL_23]] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:      function.def @constrain(
// CHECK-SAME:            %[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@c] : <@A<[]>>, !array.type<2,1 x !struct.type<@C<[]>>>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@c$inputs] : <@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@b] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@b$inputs] : <@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-DAG:         %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         scf.for %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_29]] to %[[VAL_31]] step %[[VAL_30]] {
// CHECK-DAG:           scf.for %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_29]] to %[[VAL_32]] step %[[VAL_30]] {
// CHECK-DAG:             %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_33]], %[[VAL_34]]] : <2,1 x !struct.type<@C<[]>>>, !struct.type<@C<[]>>
// CHECK-DAG:             %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_33]], %[[VAL_34]]] : <2,1 x !pod.type<[@f: !felt.type]>>, !pod.type<[@f: !felt.type]>
// CHECK-DAG:             %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@f] : <[@f: !felt.type]>, !felt.type
// CHECK-DAG:             function.call @C::@constrain(%[[VAL_35]], %[[VAL_37]]) : (!struct.type<@C<[]>>, !felt.type) -> ()
// CHECK-DAG:           }
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@x] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !felt.type
// CHECK-DAG:         %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@y] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-DAG:         function.call @B::@constrain(%[[VAL_27]], %[[VAL_38]], %[[VAL_39]]) : (!struct.type<@B<[]>>, !felt.type, !array.type<10 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
