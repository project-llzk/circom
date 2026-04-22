// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(N){
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
  signal output branch;
  component a;

  if(N > 0){
     a = A(N+2);
     branch <== 1;
  }
  else{
     a = A(N+1);
     branch <== 0;
  }
  a.in <== 1;
  a.out ==> out;
}
template D() {
  component b0 = B(0);
  component b1 = B(1);

  signal output outs[2];
  signal output branches[2];
  outs[0] <== b0.out;
  outs[1] <== b1.out;
  branches[0] <== b0.branch;
  branches[1] <== b1.branch;
}

component main = D();

// CHECK-LABEL: module attributes {
