// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template A() {
    signal input {binary} in;
    signal intermediate;
    signal output {binary} out;
    intermediate <== in;
    out <== intermediate;
}

template Caller(){
    signal input inp;
    signal output out;
    component a = A();
    a.in <== inp;
    out <== a.out;
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Caller<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.member @intermediate : !felt.type
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_1]][@intermediate] = %[[VAL_0]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@intermediate] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_5]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Caller<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @a : !struct.type<@A<[]>>
// CHECK-NEXT:      struct.member @a$inputs : !pod.type<[@in: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[]>>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_10]][@in] = %[[VAL_6]] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@count] : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_11]], %[[VAL_12]] : index
// CHECK-NEXT:        pod.write %[[VAL_9]][@count] = %[[VAL_13]] : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:        scf.if %[[VAL_15]] {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_16]]) : (!felt.type) -> !struct.type<@A<[]>>
// CHECK-NEXT:          pod.write %[[VAL_9]][@comp] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@comp] : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A<[]>>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_7]][@out] = %[[VAL_19]] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_7]][@a$inputs] = %[[VAL_10]] : <@Caller<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@comp] : <[@count: index, @comp: !struct.type<@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_7]][@a] = %[[VAL_20]] : <@Caller<[]>>, !struct.type<@A<[]>>
// CHECK-NEXT:        function.return %[[VAL_7]] : !struct.type<@Caller<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[]>>, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@a] : <@Caller<[]>>, !struct.type<@A<[]>>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@a$inputs] : <@Caller<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_26]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_23]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_24]], %[[VAL_28]]) : (!struct.type<@A<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
