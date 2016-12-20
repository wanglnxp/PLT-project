; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

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
  ret i32 0
}
