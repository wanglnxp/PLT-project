; Vdecl b
; Return
; Vdecl a
; Vdecl b
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
  %b = alloca i32
  %a2 = load i32, i32* %a1
  %tmp = add i32 %a2, 1
  store i32 %tmp, i32* %a1
  store i32 100, i32* %b
  %a3 = load i32, i32* %a1
  ret i32 %a3
}

define i32 @main() {
entry:
  %bbb = alloca i32
  %b = alloca %person
  %a = alloca %person
  %name = getelementptr inbounds %person, %person* %a, i32 0, i32 2
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str, i32 0, i32 0), i8** %name
  %name1 = getelementptr inbounds %person, %person* %b, i32 0, i32 2
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str.8, i32 0, i32 0), i8** %name1
  store i32 0, i32* %bbb
  %bbb2 = load i32, i32* %bbb
  %change_result = call i32 @change(i32 %bbb2)
  ret i32 0
}
