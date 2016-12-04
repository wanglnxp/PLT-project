; ModuleID = 'MicroC'

@b = global i1 false
@test = global [10 x i8] c"1234567890"
@y = global i8* null
@test.1 = global [10 x i8] c"1234567890"
@x = global i8* null
@c = global double 2.000000e+00
@a = global i32 1
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.8 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [6 x i8] c"hello\00"
@str.9 = private unnamed_addr constant [6 x i8] c"hello\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @foo() {
entry:
  ret i32 10
}

define i32 @main() {
entry:
  %a = alloca i32
  %foo_result = call i32 @foo()
  %foo_result1 = call i32 @foo()
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.5, i32 0, i32 0), i32 %foo_result1)
  %c = load double, double* @c
  %c2 = load double, double* @c
  %printf3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.6, i32 0, i32 0), double %c2)
  %print_number = call i32 @print_number(i32 1)
  store i32 %print_number, i32* %a
  %a4 = load i32, i32* %a
  %a5 = load i32, i32* %a
  %printf6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.5, i32 0, i32 0), i32 %a5)
  %printf7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.8, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str.9, i32 0, i32 0))
  ret i32 0
}
