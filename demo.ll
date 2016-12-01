; ModuleID = 'MicroC'

@b = global i1 false
@x = global i8* null
@c = global double 2.000000e+00
@a = global i32 1
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [22 x i8] c"%d ? \22true\22 : \22false\22\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [22 x i8] c"%d ? \22true\22 : \22false\22\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [6 x i8] c"12345\00"
@str.8 = private unnamed_addr constant [12 x i8] c"hello niubi\00"
@str.9 = private unnamed_addr constant [6 x i8] c"hello\00"
@str.10 = private unnamed_addr constant [6 x i8] c"hello\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @foo() {
entry:
  %a = load i32, i32* @a
  %a1 = load i32, i32* @a
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %a1)
  ret i32 0
}

define i32 @main() {
entry:
  %t = alloca i32
  %test = alloca i8*
  %foo_result = call i32 @foo()
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str, i32 0, i32 0), i8** %test
  store i32 5, i32* @a
  store i32 5, i32* %t
  %t1 = load i32, i32* %t
  %t2 = load i32, i32* %t
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i32 %t2)
  store i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str.8, i32 0, i32 0), i8** @x
  %x = load i8*, i8** @x
  %x3 = load i8*, i8** @x
  %printf4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.7, i32 0, i32 0), i8* %x3)
  %c = load double, double* @c
  %c5 = load double, double* @c
  %printf6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.5, i32 0, i32 0), double %c5)
  %printf7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i1 true)
  %printf8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.7, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str.10, i32 0, i32 0))
  ret i32 0
}
