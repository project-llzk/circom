// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller::@Caller<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @intermediate : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@intermediate] = %[[VAL_0]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@intermediate] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]], @params = %[[VAL_9]] }  : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_8]][@in] = %[[VAL_6]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          pod.write %[[VAL_11]][@count] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          scf.if %[[VAL_16]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_18]]) : (!felt.type<"bn128">) -> !struct.type<@A::@A<[]>>
// CHECK-NEXT:            pod.write %[[VAL_11]][@comp] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_7]][@out] = %[[VAL_21]] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_7]][@a$inputs] = %[[VAL_8]] : <@Caller::@Caller<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_7]][@a] = %[[VAL_22]] : <@Caller::@Caller<[]>>, !struct.type<@A::@A<[]>>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@out] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@a] : <@Caller::@Caller<[]>>, !struct.type<@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@a$inputs] : <@Caller::@Caller<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@A::@A<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_31]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@out] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_25]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_26]], %[[VAL_33]]) : (!struct.type<@A::@A<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
