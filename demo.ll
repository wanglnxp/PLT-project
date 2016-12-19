; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

@n = global %struct.NodeList* null
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @print_bool(i32)

declare %struct.NodeList* @init_List()

declare %struct.NodeList* @add_back(%struct.NodeList*, i8*)

declare i8* @int_to_pointer(i32)

declare i8* @float_to_pointer(double)

declare i32 @pointer_to_int(i8*)

declare double @pointer_to_float(i8*)

declare i8* @index_acess(%struct.NodeList*, i32)

declare i32 @length(%struct.NodeList*)

declare i32 @remove_node(%struct.NodeList*, i32)

declare i32 @node_change(%struct.NodeList*, i32, i8*)

define i32 @main() {
entry:
  %n = alloca %struct.NodeList*
  %init = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init, %struct.NodeList** %n
  %n1 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp = call i8* @int_to_pointer(i32 10)
  %tmp2 = call %struct.NodeList* @add_back(%struct.NodeList* %n1, i8* %tmp)
  %n3 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp4 = call i8* @int_to_pointer(i32 20)
  %tmp5 = call %struct.NodeList* @add_back(%struct.NodeList* %n3, i8* %tmp4)
  %n6 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp7 = call i8* @int_to_pointer(i32 100)
  %tmp8 = call i32 @node_change(%struct.NodeList* %n6, i32 0, i8* %tmp7)
  %n9 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp10 = call i8* @index_acess(%struct.NodeList* %n9, i32 0)
  %tmp11 = call i32 @pointer_to_int(i8* %tmp10)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp11)
  ret i32 0
}
