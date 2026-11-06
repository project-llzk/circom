// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

// Acyclic wrappers must not consume the recursive specialization depth budget.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else {
        component child = R(n - 1, a);
        out <== child.out;
    }
}

template W000(n, a) { component child = W001(n, a); signal output out; out <== child.out; }
template W001(n, a) { component child = W002(n, a); signal output out; out <== child.out; }
template W002(n, a) { component child = W003(n, a); signal output out; out <== child.out; }
template W003(n, a) { component child = W004(n, a); signal output out; out <== child.out; }
template W004(n, a) { component child = W005(n, a); signal output out; out <== child.out; }
template W005(n, a) { component child = W006(n, a); signal output out; out <== child.out; }
template W006(n, a) { component child = W007(n, a); signal output out; out <== child.out; }
template W007(n, a) { component child = W008(n, a); signal output out; out <== child.out; }
template W008(n, a) { component child = W009(n, a); signal output out; out <== child.out; }
template W009(n, a) { component child = W010(n, a); signal output out; out <== child.out; }
template W010(n, a) { component child = W011(n, a); signal output out; out <== child.out; }
template W011(n, a) { component child = W012(n, a); signal output out; out <== child.out; }
template W012(n, a) { component child = W013(n, a); signal output out; out <== child.out; }
template W013(n, a) { component child = W014(n, a); signal output out; out <== child.out; }
template W014(n, a) { component child = W015(n, a); signal output out; out <== child.out; }
template W015(n, a) { component child = W016(n, a); signal output out; out <== child.out; }
template W016(n, a) { component child = W017(n, a); signal output out; out <== child.out; }
template W017(n, a) { component child = W018(n, a); signal output out; out <== child.out; }
template W018(n, a) { component child = W019(n, a); signal output out; out <== child.out; }
template W019(n, a) { component child = W020(n, a); signal output out; out <== child.out; }
template W020(n, a) { component child = W021(n, a); signal output out; out <== child.out; }
template W021(n, a) { component child = W022(n, a); signal output out; out <== child.out; }
template W022(n, a) { component child = W023(n, a); signal output out; out <== child.out; }
template W023(n, a) { component child = W024(n, a); signal output out; out <== child.out; }
template W024(n, a) { component child = W025(n, a); signal output out; out <== child.out; }
template W025(n, a) { component child = W026(n, a); signal output out; out <== child.out; }
template W026(n, a) { component child = W027(n, a); signal output out; out <== child.out; }
template W027(n, a) { component child = W028(n, a); signal output out; out <== child.out; }
template W028(n, a) { component child = W029(n, a); signal output out; out <== child.out; }
template W029(n, a) { component child = W030(n, a); signal output out; out <== child.out; }
template W030(n, a) { component child = W031(n, a); signal output out; out <== child.out; }
template W031(n, a) { component child = W032(n, a); signal output out; out <== child.out; }
template W032(n, a) { component child = W033(n, a); signal output out; out <== child.out; }
template W033(n, a) { component child = W034(n, a); signal output out; out <== child.out; }
template W034(n, a) { component child = W035(n, a); signal output out; out <== child.out; }
template W035(n, a) { component child = W036(n, a); signal output out; out <== child.out; }
template W036(n, a) { component child = W037(n, a); signal output out; out <== child.out; }
template W037(n, a) { component child = W038(n, a); signal output out; out <== child.out; }
template W038(n, a) { component child = W039(n, a); signal output out; out <== child.out; }
template W039(n, a) { component child = W040(n, a); signal output out; out <== child.out; }
template W040(n, a) { component child = W041(n, a); signal output out; out <== child.out; }
template W041(n, a) { component child = W042(n, a); signal output out; out <== child.out; }
template W042(n, a) { component child = W043(n, a); signal output out; out <== child.out; }
template W043(n, a) { component child = W044(n, a); signal output out; out <== child.out; }
template W044(n, a) { component child = W045(n, a); signal output out; out <== child.out; }
template W045(n, a) { component child = W046(n, a); signal output out; out <== child.out; }
template W046(n, a) { component child = W047(n, a); signal output out; out <== child.out; }
template W047(n, a) { component child = W048(n, a); signal output out; out <== child.out; }
template W048(n, a) { component child = W049(n, a); signal output out; out <== child.out; }
template W049(n, a) { component child = W050(n, a); signal output out; out <== child.out; }
template W050(n, a) { component child = W051(n, a); signal output out; out <== child.out; }
template W051(n, a) { component child = W052(n, a); signal output out; out <== child.out; }
template W052(n, a) { component child = W053(n, a); signal output out; out <== child.out; }
template W053(n, a) { component child = W054(n, a); signal output out; out <== child.out; }
template W054(n, a) { component child = W055(n, a); signal output out; out <== child.out; }
template W055(n, a) { component child = W056(n, a); signal output out; out <== child.out; }
template W056(n, a) { component child = W057(n, a); signal output out; out <== child.out; }
template W057(n, a) { component child = W058(n, a); signal output out; out <== child.out; }
template W058(n, a) { component child = W059(n, a); signal output out; out <== child.out; }
template W059(n, a) { component child = W060(n, a); signal output out; out <== child.out; }
template W060(n, a) { component child = W061(n, a); signal output out; out <== child.out; }
template W061(n, a) { component child = W062(n, a); signal output out; out <== child.out; }
template W062(n, a) { component child = W063(n, a); signal output out; out <== child.out; }
template W063(n, a) { component child = W064(n, a); signal output out; out <== child.out; }
template W064(n, a) { component child = W065(n, a); signal output out; out <== child.out; }
template W065(n, a) { component child = W066(n, a); signal output out; out <== child.out; }
template W066(n, a) { component child = W067(n, a); signal output out; out <== child.out; }
template W067(n, a) { component child = W068(n, a); signal output out; out <== child.out; }
template W068(n, a) { component child = W069(n, a); signal output out; out <== child.out; }
template W069(n, a) { component child = W070(n, a); signal output out; out <== child.out; }
template W070(n, a) { component child = W071(n, a); signal output out; out <== child.out; }
template W071(n, a) { component child = W072(n, a); signal output out; out <== child.out; }
template W072(n, a) { component child = W073(n, a); signal output out; out <== child.out; }
template W073(n, a) { component child = W074(n, a); signal output out; out <== child.out; }
template W074(n, a) { component child = W075(n, a); signal output out; out <== child.out; }
template W075(n, a) { component child = W076(n, a); signal output out; out <== child.out; }
template W076(n, a) { component child = W077(n, a); signal output out; out <== child.out; }
template W077(n, a) { component child = W078(n, a); signal output out; out <== child.out; }
template W078(n, a) { component child = W079(n, a); signal output out; out <== child.out; }
template W079(n, a) { component child = W080(n, a); signal output out; out <== child.out; }
template W080(n, a) { component child = W081(n, a); signal output out; out <== child.out; }
template W081(n, a) { component child = W082(n, a); signal output out; out <== child.out; }
template W082(n, a) { component child = W083(n, a); signal output out; out <== child.out; }
template W083(n, a) { component child = W084(n, a); signal output out; out <== child.out; }
template W084(n, a) { component child = W085(n, a); signal output out; out <== child.out; }
template W085(n, a) { component child = W086(n, a); signal output out; out <== child.out; }
template W086(n, a) { component child = W087(n, a); signal output out; out <== child.out; }
template W087(n, a) { component child = W088(n, a); signal output out; out <== child.out; }
template W088(n, a) { component child = W089(n, a); signal output out; out <== child.out; }
template W089(n, a) { component child = W090(n, a); signal output out; out <== child.out; }
template W090(n, a) { component child = W091(n, a); signal output out; out <== child.out; }
template W091(n, a) { component child = W092(n, a); signal output out; out <== child.out; }
template W092(n, a) { component child = W093(n, a); signal output out; out <== child.out; }
template W093(n, a) { component child = W094(n, a); signal output out; out <== child.out; }
template W094(n, a) { component child = W095(n, a); signal output out; out <== child.out; }
template W095(n, a) { component child = W096(n, a); signal output out; out <== child.out; }
template W096(n, a) { component child = W097(n, a); signal output out; out <== child.out; }
template W097(n, a) { component child = W098(n, a); signal output out; out <== child.out; }
template W098(n, a) { component child = W099(n, a); signal output out; out <== child.out; }
template W099(n, a) { component child = W100(n, a); signal output out; out <== child.out; }
template W100(n, a) { component child = W101(n, a); signal output out; out <== child.out; }
template W101(n, a) { component child = W102(n, a); signal output out; out <== child.out; }
template W102(n, a) { component child = W103(n, a); signal output out; out <== child.out; }
template W103(n, a) { component child = W104(n, a); signal output out; out <== child.out; }
template W104(n, a) { component child = W105(n, a); signal output out; out <== child.out; }
template W105(n, a) { component child = W106(n, a); signal output out; out <== child.out; }
template W106(n, a) { component child = W107(n, a); signal output out; out <== child.out; }
template W107(n, a) { component child = W108(n, a); signal output out; out <== child.out; }
template W108(n, a) { component child = W109(n, a); signal output out; out <== child.out; }
template W109(n, a) { component child = W110(n, a); signal output out; out <== child.out; }
template W110(n, a) { component child = W111(n, a); signal output out; out <== child.out; }
template W111(n, a) { component child = W112(n, a); signal output out; out <== child.out; }
template W112(n, a) { component child = W113(n, a); signal output out; out <== child.out; }
template W113(n, a) { component child = W114(n, a); signal output out; out <== child.out; }
template W114(n, a) { component child = W115(n, a); signal output out; out <== child.out; }
template W115(n, a) { component child = W116(n, a); signal output out; out <== child.out; }
template W116(n, a) { component child = W117(n, a); signal output out; out <== child.out; }
template W117(n, a) { component child = W118(n, a); signal output out; out <== child.out; }
template W118(n, a) { component child = W119(n, a); signal output out; out <== child.out; }
template W119(n, a) { component child = W120(n, a); signal output out; out <== child.out; }
template W120(n, a) { component child = W121(n, a); signal output out; out <== child.out; }
template W121(n, a) { component child = W122(n, a); signal output out; out <== child.out; }
template W122(n, a) { component child = W123(n, a); signal output out; out <== child.out; }
template W123(n, a) { component child = W124(n, a); signal output out; out <== child.out; }
template W124(n, a) { component child = W125(n, a); signal output out; out <== child.out; }
template W125(n, a) { component child = W126(n, a); signal output out; out <== child.out; }
template W126(n, a) { component child = W127(n, a); signal output out; out <== child.out; }
template W127(n, a) { component child = R(n, a); signal output out; out <== child.out; }

component main = W000(1, [7]);

// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1$values$0_0::
