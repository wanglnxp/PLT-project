; ModuleID = 'MicroC'

@a = global i32 2
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [6 x i8] c"flase\00"
@str.8 = private unnamed_addr constant [6 x i8] c"asdfs\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @foo(i32 %a) {
entry:
  %a1 = alloca i32
  store i32 %a, i32* %a1
  %a2 = load i32, i32* %a1
  ret i32 %a2
}

define i32 @main() {
entry:
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.7, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str, i32 0, i32 0))
  %printf1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i32 %printf)
  %printf2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.7, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str.8, i32 0, i32 0))
  %printf3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i32 %printf2)
  ret i32 0
}
