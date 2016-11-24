; ModuleID = 'MicroC'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [6 x i8] c"Hello\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %plus_result = call i32 @plus(i32 1)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %plus_result)
  %printf1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str, i32 0, i32 0))
  ret i32 0
}

define i32 @plus(i32 %a) {
entry:
  %a1 = alloca i32
  store i32 %a, i32* %a1
  %b = alloca i32
  store i32 1, i32* %b
  ret i32 1
}
