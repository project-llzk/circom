// REQUIRES: circom, llzk-opt
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext -l tests/source_locations/Inputs -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --check-prefix=CONCRETE
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete -l tests/source_locations/Inputs -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs llzk-opt --mlir-print-debuginfo | FileCheck %s --check-prefix=CONCRETE
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk templated --llzk_plaintext -l tests/source_locations/Inputs -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --check-prefix=TEMPLATED
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk templated -l tests/source_locations/Inputs -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs llzk-opt --mlir-print-debuginfo | FileCheck %s --check-prefix=TEMPLATED
// END.

pragma circom 2.0.0;

include "definitions.circom";

component main = LocatedComponent();

// CONCRETE:      #loc1 = loc("[[INCLUDE_PATH:.*source_locations/Inputs/definitions.circom]]":3:17)
// CONCRETE-NEXT: #loc5 = loc("[[INCLUDE_PATH]]":7:26)
// CONCRETE-NEXT: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@LocatedComponent_0::@LocatedComponent_0<[]>>} {
// CONCRETE-NEXT:   poly.template @Double_0 {
// CONCRETE-NEXT:     function.def @Double_0(%arg0: !felt.type<"bn128"> {function.arg_name = "value"} loc("[[INCLUDE_PATH]]":3:17)) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CONCRETE-NEXT:       %felt_const_2 = felt.const  2 : <"bn128"> loc(#loc2)
// CONCRETE-NEXT:       %0 = felt.mul %arg0, %felt_const_2 : !felt.type<"bn128">, !felt.type<"bn128"> loc(#loc3)
// CONCRETE-NEXT:       function.return %0 : !felt.type<"bn128"> loc(#loc4)
// CONCRETE-NEXT:     } loc(#loc1)
// CONCRETE-NEXT:   } loc(#loc1)
// CONCRETE-NEXT:   poly.template @LocatedComponent_0 {
// CONCRETE-NEXT:     struct.def @LocatedComponent_0 {
// CONCRETE-NEXT:       struct.member @out : !felt.type<"bn128"> {llzk.pub, signal} loc(#loc5)
// CONCRETE-NEXT:       function.def @compute(%arg0: !felt.type<"bn128"> {function.arg_name = "in"} loc("[[INCLUDE_PATH]]":7:26)) -> !struct.type<@LocatedComponent_0::@LocatedComponent_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:         %self = struct.new : <@LocatedComponent_0::@LocatedComponent_0<[]>> loc(#loc5)
// CONCRETE-NEXT:         %0 = function.call @Double_0::@Double_0(%arg0) : (!felt.type<"bn128">) -> !felt.type<"bn128">  loc(#loc6)
// CONCRETE-NEXT:         struct.writem %self[@out] = %0 : <@LocatedComponent_0::@LocatedComponent_0<[]>>, !felt.type<"bn128"> loc(#loc7)
// CONCRETE-NEXT:         function.return %self : !struct.type<@LocatedComponent_0::@LocatedComponent_0<[]>> loc(#loc5)
// CONCRETE-NEXT:       } loc(#loc5)
// CONCRETE-NEXT:       function.def @constrain(%arg0: !struct.type<@LocatedComponent_0::@LocatedComponent_0<[]>> loc("[[INCLUDE_PATH]]":7:26), %arg1: !felt.type<"bn128"> {function.arg_name = "in"} loc("[[INCLUDE_PATH]]":7:26)) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:         %0 = struct.readm %arg0[@out] : <@LocatedComponent_0::@LocatedComponent_0<[]>>, !felt.type<"bn128"> loc(#loc8)
// CONCRETE-NEXT:         %1 = function.call @Double_0::@Double_0(%arg1) : (!felt.type<"bn128">) -> !felt.type<"bn128">  loc(#loc6)
// CONCRETE-NEXT:         constrain.eq %0, %1 : !felt.type<"bn128">, !felt.type<"bn128"> loc(#loc7)
// CONCRETE-NEXT:         function.return loc(#loc5)
// CONCRETE-NEXT:       } loc(#loc5)
// CONCRETE-NEXT:     } loc(#loc5)
// CONCRETE-NEXT:   } loc(#loc5)
// CONCRETE-NEXT: } loc(#loc)
// CONCRETE-NEXT: #loc = loc("{{.*concrete_definitions.*circom}}":12:18)
// CONCRETE-NEXT: #loc2 = loc("[[INCLUDE_PATH]]":4:20)
// CONCRETE-NEXT: #loc3 = loc("[[INCLUDE_PATH]]":4:12)
// CONCRETE-NEXT: #loc4 = loc("[[INCLUDE_PATH]]":4:5)
// CONCRETE-NEXT: #loc6 = loc("[[INCLUDE_PATH]]":11:13)
// CONCRETE-NEXT: #loc7 = loc("[[INCLUDE_PATH]]":11:5)
// CONCRETE-NEXT: #loc8 = loc(unknown)

// TEMPLATED:      #loc1 = loc("[[INCLUDE_PATH:.*source_locations/Inputs/definitions.circom]]":3:17)
// TEMPLATED-NEXT: #loc5 = loc("[[INCLUDE_PATH]]":7:26)
// TEMPLATED-NEXT: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@LocatedComponent::@LocatedComponent<[]>>} {
// TEMPLATED-NEXT:   poly.template @Double {
// TEMPLATED-NEXT:     poly.param @T_arg0 : !poly.tvar<@T_arg0> loc(#loc1)
// TEMPLATED-NEXT:     poly.param @T_return : !poly.tvar<@T_return> loc(#loc1)
// TEMPLATED-NEXT:     function.def @Double(%arg0: !poly.tvar<@T_arg0> {function.arg_name = "value"} loc("[[INCLUDE_PATH]]":3:17)) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:       %felt_const_2 = felt.const  2 : <"bn128"> loc(#loc2)
// TEMPLATED-NEXT:       %0 = poly.unifiable_cast %arg0 : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128"> loc(#loc3)
// TEMPLATED-NEXT:       %1 = felt.mul %0, %felt_const_2 : !felt.type<"bn128">, !felt.type<"bn128"> loc(#loc3)
// TEMPLATED-NEXT:       %2 = poly.unifiable_cast %1 : (!felt.type<"bn128">) -> !poly.tvar<@T_return> loc(#loc4)
// TEMPLATED-NEXT:       function.return %2 : !poly.tvar<@T_return> loc(#loc4)
// TEMPLATED-NEXT:     } loc(#loc1)
// TEMPLATED-NEXT:   } loc(#loc1)
// TEMPLATED-NEXT:   poly.template @LocatedComponent {
// TEMPLATED-NEXT:     struct.def @LocatedComponent {
// TEMPLATED-NEXT:       struct.member @out : !felt.type<"bn128"> {llzk.pub, signal} loc(#loc6)
// TEMPLATED-NEXT:       function.def @compute(%arg0: !felt.type<"bn128"> {function.arg_name = "in"} loc("[[INCLUDE_PATH]]":7:26)) -> !struct.type<@LocatedComponent::@LocatedComponent<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:         %self = struct.new : <@LocatedComponent::@LocatedComponent<[]>> loc(#loc5)
// TEMPLATED-NEXT:         %0 = function.call @Double::@Double(%arg0) : (!felt.type<"bn128">) -> !felt.type<"bn128">  loc(#loc7)
// TEMPLATED-NEXT:         struct.writem %self[@out] = %0 : <@LocatedComponent::@LocatedComponent<[]>>, !felt.type<"bn128"> loc(#loc8)
// TEMPLATED-NEXT:         function.return %self : !struct.type<@LocatedComponent::@LocatedComponent<[]>> loc(#loc5)
// TEMPLATED-NEXT:       } loc(#loc5)
// TEMPLATED-NEXT:       function.def @constrain(%arg0: !struct.type<@LocatedComponent::@LocatedComponent<[]>> loc("[[INCLUDE_PATH]]":7:26), %arg1: !felt.type<"bn128"> {function.arg_name = "in"} loc("[[INCLUDE_PATH]]":7:26)) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:         %0 = struct.readm %arg0[@out] : <@LocatedComponent::@LocatedComponent<[]>>, !felt.type<"bn128"> loc(#loc9)
// TEMPLATED-NEXT:         %1 = function.call @Double::@Double(%arg1) : (!felt.type<"bn128">) -> !felt.type<"bn128">  loc(#loc7)
// TEMPLATED-NEXT:         constrain.eq %0, %1 : !felt.type<"bn128">, !felt.type<"bn128"> loc(#loc8)
// TEMPLATED-NEXT:         function.return loc(#loc5)
// TEMPLATED-NEXT:       } loc(#loc5)
// TEMPLATED-NEXT:     } loc(#loc5)
// TEMPLATED-NEXT:   } loc(#loc5)
// TEMPLATED-NEXT: } loc(#loc)
// TEMPLATED-NEXT: #loc = loc("{{.*concrete_definitions.*circom}}":12:18)
// TEMPLATED-NEXT: #loc2 = loc("[[INCLUDE_PATH]]":4:20)
// TEMPLATED-NEXT: #loc3 = loc("[[INCLUDE_PATH]]":4:12)
// TEMPLATED-NEXT: #loc4 = loc("[[INCLUDE_PATH]]":4:5)
// TEMPLATED-NEXT: #loc6 = loc("[[INCLUDE_PATH]]":9:5)
// TEMPLATED-NEXT: #loc7 = loc("[[INCLUDE_PATH]]":11:13)
// TEMPLATED-NEXT: #loc8 = loc("[[INCLUDE_PATH]]":11:5)
// TEMPLATED-NEXT: #loc9 = loc(unknown)
