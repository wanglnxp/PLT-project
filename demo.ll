; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @print_bool(i32)

declare i32 @system(i8*)

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

define void @func(i32 %i) {
entry:
  %i1 = alloca i32
  store i32 %i, i32* %i1
  %i2 = load i32, i32* %i1
  %i3 = load i32, i32* %i1
  %tmp = add i32 %i2, %i3
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp)
  ret void
}

define i32 @main() {
entry:
  %n = alloca %struct.NodeList*
  %init = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init, %struct.NodeList** %n
  %l = alloca %struct.NodeList*
  %init1 = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init1, %struct.NodeList** %l
  %n2 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp = call i8* @int_to_pointer(i32 10)
  %tmp3 = call %struct.NodeList* @add_back(%struct.NodeList* %n2, i8* %tmp)
  %l4 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp5 = call i8* @int_to_pointer(i32 3)
  %tmp6 = call %struct.NodeList* @add_back(%struct.NodeList* %l4, i8* %tmp5)
  %n7 = load %struct.NodeList*, %struct.NodeList** %n
  %l8 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp9 = call i8* @index_acess(%struct.NodeList* %l8, i32 0)
  %tmp10 = call i32 @pointer_to_int(i8* %tmp9)
  %tmp11 = call i8* @int_to_pointer(i32 %tmp10)
  %tmp12 = call i32 @node_change(%struct.NodeList* %n7, i32 0, i8* %tmp11)
  %n13 = load %struct.NodeList*, %struct.NodeList** %n
  %tmp14 = call i8* @index_acess(%struct.NodeList* %n13, i32 0)
  %tmp15 = call i32 @pointer_to_int(i8* %tmp14)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.4, i32 0, i32 0), i32 %tmp15)
  ret i32 2
}
