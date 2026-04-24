// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(N, M){
   signal input in;
   signal output out;
   out <== in;
}
template C(N){
   signal output out;
   out <== N;
}
template B(N){
  signal output out;
  component a[1];
  if(N > 0){
     a[0] = A(N, 1);
  }
  else{
     a[0] = A(0, 1);
  }
  a[0].in <== 1;
  a[0].out ==> out;
}

component main = B(1);

// CHECK-LABEL: module attributes {
