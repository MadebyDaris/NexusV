define i32 @nexus_mac(i32 %acc, i32 %a, i32 %b) {
entry:
  %prod = mul i32 %a, %b
  %result = add i32 %acc, %prod
  ret i32 %result
}