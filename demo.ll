; Vdecl b
; Vdecl c
; Return
; Vdecl a
; Vdecl b
; print
; SAccessb
; Vdecl bbb
; ModuleID = 'MicroC'

%person = type <{ i32, i32, i8* }>

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [4 x i8] c"100\00"
@str.8 = private unnamed_addr constant [4 x i8] c"200\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @change(i32 %a) {
entry:
  %a1 = alloca i32
  store i32 %a, i32* %a1
  %c = alloca double
  %b = alloca i32
  store i32 10, i32* %a1
  store i32 100, i32* %b
  store double 1.203000e+01, double* %c
  %a2 = load i32, i32* %a1
  ret i32 %a2
}

define i32 @main() {
entry:
  %bbb = alloca i32
  %b = alloca %person
  %a = alloca %person
  %age = getelementptr inbounds %person, %person* %b, i32 0, i32 1
  store i32 9, i32* %age
  %age1 = getelementptr inbounds %person, %person* %b, i32 0, i32 1
  %age2 = load i32, i32* %age1
  %tmp = add i32 %age2, 10
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i32 %tmp)
  %name = getelementptr inbounds %person, %person* %a, i32 0, i32 2
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str, i32 0, i32 0), i8** %name
  %name3 = getelementptr inbounds %person, %person* %b, i32 0, i32 2
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str.8, i32 0, i32 0), i8** %name3
  store i32 0, i32* %bbb
  %bbb4 = load i32, i32* %bbb
  %change_result = call i32 @change(i32 %bbb4)
  ret i32 0
}
