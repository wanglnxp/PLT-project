; ModuleID = 'MicroC'

@fmt = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [6 x i8] c"Hello\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str, i32 0, i32 0))
  ret i32 0
}
