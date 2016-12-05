; ModuleID = 'MicroC'

%person = type <{ i32, i32, i8* }>

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [5 x i8] c"Good\00"

declare i32 @printf(i8*, ...)

declare i32 @print_number(i32)

define i32 @main() {
entry:
  %a = alloca %person
  %name = getelementptr inbounds %person, %person* %a, i32 0, i32 2
  store i8* getelementptr inbounds ([5 x i8], [5 x i8]* @str, i32 0, i32 0), i8** %name
  %name1 = getelementptr inbounds %person, %person* %a, i32 0, i32 2
  %name2 = load i8*, i8** %name1
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.3, i32 0, i32 0), i8* %name2)
  ret i32 0
}
