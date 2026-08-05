# Mock LLVM text
Here are some mock test of what the llvm would look like from after the compiler part is done.

## Mock examples
This is the simplest test case. It proves the parser can read an addition operation and figure out the inputs and outputs.

```llvm
define i32 @nexus_add(i32 %a, i32 %b) {
entry:
  %result = add i32 %a, %b
  ret i32 %result
}
```

```llvm
define i32 @nexus_mac(i32 %acc, i32 %a, i32 %b) {
entry:
  %prod = mul i32 %a, %b
  %result = add i32 %acc, %prod
  ret i32 %result
}
```
Once we move towards MAC operations it gets already pretty complicated, we need a way to make this simplified and easily parsed.

Current candidate is GPUCompile.jl (Metal.jl is to be observed for apple silicon GPU compilation).

Next steps is to create a custom "Compiler Job" that takes the function captured in Task A.1 and forces Julia to translate it into raw, OS-independent LLVM IR text.
