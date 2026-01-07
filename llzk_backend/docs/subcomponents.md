# Subcomponent lowering

This document gives a high-level overview of how subcomponents are lowered to
LLZK.

## 1. Subcomponent detection

During the *declaration info* phase the backend collects all the subcomponent
declarations and the instances assigned to them. For each declaration the
backend collects the name of the subcomponent and the dimensions if it was
declared as an array of subcomponents.

For each instance the backend collects the type that was instantiated for that
subcomponent. Currently the backend only supports scalar subcomponents or array
subcomponents in which all instances are of the same type.

```
// Supported 
component a;
a = A(X);

component b[N];
b[0] = B(X);
b[1] = B(X);

// Not yet supported
component c[N];
c[0] = C(X);
c[1] = C(Y);
```

For each subcomponent detected in this phase the backend creates a field in the
struct and adds the name to the scope in preparation for lowering.

## 2. Subcomponent lowering

### Subcomponent constructors

Call expressions that create a new subcomponent are translated to calls to
`@compute`/`@constrain`. Since the call is an expression, it needs to return a
value. In the case of `@compute` that is the operation's result and in the case
of `@constrain` is the first argument of the function. Refering to a
subcomponent by name is refering to this value. The second piece of the
construction is an assign var statement. When a variable tied to a subcomponent
gets assigned it does different things depending on the function. In `@compute`
updates the its value with the result of lowering the right hand expression. In
the case of `@constrain` the value gets replaced with a `struct.readf` that
reads the field with the same name as the subcomponent.

The inputs of the template (the arguments of `@compute` and `@constrain`) are
filled with `undef.undef` placeholders.

### Subcomponent signal write

When a subcomponent signal is assigned (with either `<--` or `<==`) the backend
first finds what argument number corresponds to the signal. Then replaces the
corresponding argument with the value generated from the right hand expression.
Lastly, reorders the operations if it's necessary for ensuring dominance. In the
case of `<==` this process is done for both `@compute` and `@constrain`, while
for `<--` it only does it for `@compute`.

For the handling of `===` see below.

### Subcomponent signal read

When reading a subcomponent signal the backend first checks if it's an input or
an output (or intermediate, which is an error). If the signal is an input then
locates the corresponding argument to the function, similar to how writing
works. If the signal is an output generates a `struct.readf` operation that
reads the signal from the subcomponent.

## 3. Subcomponent writing

Once lowering is complete, the backend inserts `struct.writef` operations for
each subcomponent using the value in the scope associated to the subcomponent's
name.
