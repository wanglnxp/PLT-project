; Vdecl c
; print
; print
; print
; print
; Return
; Return
; ModuleID = 'MicroC'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @test(i32 %a) {
entry:
  %a1 = alloca i32
  store i32 %a, i32* %a1
  %c = alloca double
  store i32 8, i32* %a1
  store double 1.203000e+01, double* %c
  store double 1.790000e+01, double* %c
  %c2 = load double, double* %c
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), double %c2)
  %a3 = load i32, i32* %a1
  %x = sitofp i32 %a3 to double
  %tmp = fadd double %x, 9.900000e+00
  store double %tmp, double* %c
  %c4 = load double, double* %c
  %printf5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), double %c4)
  store double 1.890000e+01, double* %c
  %c6 = load double, double* %c
  %printf7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), double %c6)
  %a8 = load i32, i32* %a1
  %x9 = sitofp i32 %a8 to double
  %tmp10 = fadd double 1.090000e+01, %x9
  store double %tmp10, double* %c
  %c11 = load double, double* %c
  %printf12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), double %c11)
  %a13 = load i32, i32* %a1
  ret i32 %a13
}

define i32 @main() {
entry:
  %test_result = call i32 @test(i32 1)
  ret i32 0
}
