; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

@l = global %struct.NodeList* null
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @print_bool(i32)

declare %struct.NodeList* @init_List()

declare %struct.NodeList* @add_back(%struct.NodeList*, i8*)

declare i8* @index_acess(%struct.NodeList*, i32)

declare i8* @int_to_pointer(i32)

declare i8* @float_to_pointer(double)

declare i32 @pointer_to_int(i8*)

declare double @pointer_to_float(i8*)

declare i32 @length(%struct.NodeList*)

define i32 @main() {
entry:
  %l = alloca %struct.NodeList*
  %init = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init, %struct.NodeList** %l
  %l1 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp = call i8* @int_to_pointer(i32 12)
  %tmp2 = call %struct.NodeList* @add_back(%struct.NodeList* %l1, i8* %tmp)
  store %struct.NodeList* %tmp2, %struct.NodeList** %l
  %l3 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp4 = call i8* @int_to_pointer(i32 2)
  %tmp5 = call %struct.NodeList* @add_back(%struct.NodeList* %l3, i8* %tmp4)
  store %struct.NodeList* %tmp5, %struct.NodeList** %l
  %l6 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp7 = call i8* @index_acess(%struct.NodeList* %l6, i32 0)
  %tmp8 = call i32 @pointer_to_int(i8* %tmp7)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp8)
  %l9 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp10 = call i8* @index_acess(%struct.NodeList* %l9, i32 2)
  %tmp11 = call i32 @pointer_to_int(i8* %tmp10)
  %printf12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp11)
  ret i32 0
}
