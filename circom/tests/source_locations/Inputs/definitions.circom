pragma circom 2.0.0;

function Double(value) {
    return value * 2;
}

template LocatedComponent() {
    signal input in;
    signal output out;

    out <== Double(in);
}
