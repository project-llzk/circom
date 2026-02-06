// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output x;

    x <== a * b;
}

template Call1() {
    signal input m;
    signal input n;
    signal output y;

    component a = B();
    a.a <== m;
    a.b <== n;
    // Call to B::compute should happen here
    y <== a.x;
}

component main = Call1();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Call1<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.member @x : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_2]][@x] = %[[VAL_3]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Call1<[]> {
// CHECK-NEXT:      struct.member @y : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @a : !struct.type<@B<[]>>
// CHECK-NEXT:      struct.member @a$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Call1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.new : <@Call1<[]>>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]] }  : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_14]][@a] = %[[VAL_9]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:        pod.write %[[VAL_13]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:        scf.if %[[VAL_19]] {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_20]], %[[VAL_21]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          pod.write %[[VAL_13]][@comp] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        pod.write %[[VAL_14]][@b] = %[[VAL_10]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_23]], %[[VAL_24]] : index
// CHECK-NEXT:        pod.write %[[VAL_13]][@count] = %[[VAL_25]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:        scf.if %[[VAL_27]] {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_28]], %[[VAL_29]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          pod.write %[[VAL_13]][@comp] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_11]][@y] = %[[VAL_32]] : <@Call1<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_11]][@a$inputs] = %[[VAL_14]] : <@Call1<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_11]][@a] = %[[VAL_33]] : <@Call1<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_11]] : !struct.type<@Call1<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@Call1<[]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@y] : <@Call1<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@a] : <@Call1<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@a$inputs] : <@Call1<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_40]], %[[VAL_35]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_41]], %[[VAL_36]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_37]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @B::@constrain(%[[VAL_38]], %[[VAL_43]], %[[VAL_44]]) : (!struct.type<@B<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
