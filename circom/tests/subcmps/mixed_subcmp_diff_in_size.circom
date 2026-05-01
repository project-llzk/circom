// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Montgomery2Edwards() {
    signal input in[2];
    signal output out[2];
}

template SegmentMulFix(nWindows) {
    signal input e[nWindows*3];
    signal input base[2];
    signal output dbl[2];
}

template EscalarMulFix(n, BASE) {
    signal input emfIn[n];

    var nsegments = (n-1)\246 +1;               // 2
    var nlastsegment = n - (nsegments-1)*249;   // 4

    component segments[nsegments];
    component m2e[nsegments-1];

    for (var s=0; s<nsegments; s++) {
        var nseg = (s < nsegments-1) ? 249 : nlastsegment;
        var nWindows = ((nseg - 1)\3)+1;

        segments[s] = SegmentMulFix(nWindows);

        for (var i=0; i<nseg; i++) {
            segments[s].e[i] <== emfIn[s*249+i];
        }

        for (var i = nseg; i<nWindows*3; i++) {
            segments[s].e[i] <== 0;
        }

        if (s==0) {
            segments[s].base[0] <== BASE[0];
            segments[s].base[1] <== BASE[1];
        } else {
            m2e[s-1] = Montgomery2Edwards();

            segments[s-1].dbl[0] ==> m2e[s-1].in[0];
            segments[s-1].dbl[1] ==> m2e[s-1].in[1];

            m2e[s-1].out[0] ==> segments[s].base[0];
            m2e[s-1].out[1] ==> segments[s].base[1];
        }
    }
}

template BabyPbk() {
    signal input in;

    var BASE8[2] = [
        5299619240641551281634865583518297030282874472190772894086521144482721001553,
        16950150798460657717958625567821834550301663161624707787222815936182638968203
    ];

    component mulFix = EscalarMulFix(253, BASE8);
    for (var i=0; i<253; i++) {
        mulFix.emfIn[i] <== in;
    }
}

component main = BabyPbk();

