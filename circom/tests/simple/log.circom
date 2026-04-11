// REQUIRES: circom
// COM: Setup and run the test
// RUN:   rm -rf %t && mkdir %t
// RUN:   %circom --stabilize --llzk --llzk_plaintext -o %t %s > %t/stdout.txt 2> %t/stderr.txt
// COM: Check stderr for the warning that's produced (but ignore the color codes)
// RUN:   sed 's/\x1b\[[0-9;]*m//g' %t/stderr.txt | FileCheck %s --check-prefix=WARN
// COM: Check stdout for the generated IR
// RUN:   sed -n 's/.*Written successfully:.* \(.*\)/\1/p' %t/stdout.txt | xargs cat | FileCheck %s --check-prefix=IR
// END.

pragma circom 2.0.0;

template A() {
  log(1658);
}

component main = A();

//WARN-LABEL: warning[T2038]: log calls are not currently supported in LLZK
// WARN-NEXT:    ┌─ "{{.*}}log.circom":14:3
// WARN-NEXT:    │
// WARN-NEXT: 14 │   log(1658);
// WARN-NEXT:    │   ^^^^^^^^^^ here

//IR-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[]>>} {
// IR-NEXT:    poly.template @A {
// IR-NEXT:      struct.def @A {
// IR-NEXT:        function.def @compute() -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// IR-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// IR-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[]>>
// IR-NEXT:        }
// IR-NEXT:        function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// IR-NEXT:          function.return
// IR-NEXT:        }
// IR-NEXT:      }
// IR-NEXT:    }
// IR-NEXT:  }
