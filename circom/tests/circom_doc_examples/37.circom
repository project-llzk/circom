// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Multiplier2() {
   signal input in1;
   signal input in2;
   signal output out <== in1 * in2;
}

//This circuit multiplies in1, in2, and in3.
template Multiplier3() {
   //Declaration of signals and components.
   signal input in1;
   signal input in2;
   signal input in3;
   signal output out;
   component mult1 = Multiplier2();
   component mult2 = Multiplier2();

   //Statements.
   mult1.in1 <== in1;
   mult1.in2 <== in2;
   mult2.in1 <== mult1.out;
   mult2.in2 <== in3;
   out <== mult2.out;
}

component main = Multiplier3();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Multiplier2<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Multiplier2<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier2<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out] = %[[VAL_3]] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier2<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Multiplier3<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @mult2 : !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:      struct.field @mult1 : !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Multiplier3<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier3<[]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@compute(%[[VAL_9]], %[[VAL_10]]) : (!felt.type, !felt.type) -> !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_13]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@compute(%[[VAL_14]], %[[VAL_11]]) : (!felt.type, !felt.type) -> !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_15]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@out] = %[[VAL_16]] : <@Multiplier3<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@mult1] = %[[VAL_13]] : <@Multiplier3<[]>>, !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_12]][@mult2] = %[[VAL_15]] : <@Multiplier3<[]>>, !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        function.return %[[VAL_12]] : !struct.type<@Multiplier3<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier3<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_17]][@mult2] : <@Multiplier3<[]>>, !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_17]][@mult1] : <@Multiplier3<[]>>, !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:        function.call @Multiplier2::@constrain(%[[VAL_22]], %[[VAL_18]], %[[VAL_19]]) : (!struct.type<@Multiplier2<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_22]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        function.call @Multiplier2::@constrain(%[[VAL_21]], %[[VAL_23]], %[[VAL_20]]) : (!struct.type<@Multiplier2<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_21]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_17]][@out] : <@Multiplier3<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_25]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

