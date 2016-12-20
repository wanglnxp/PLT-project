; int
; float
; float
; float
; float
; float
; float
; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [33 x i8] c"./lib/run  0. 0.5 -1. -1. 1. -1.\00"

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

define i32 @main() {
entry:
<<<<<<< HEAD
=======
  %a = alloca i32
  %l = alloca %struct.NodeList*
  %init = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init, %struct.NodeList** %l
  store i32 0, i32* %a
  %l1 = load %struct.NodeList*, %struct.NodeList** %l
  %a2 = load i32, i32* %a
  %tmp = call i8* @int_to_pointer(i32 %a2)
  %tmp3 = call %struct.NodeList* @add_back(%struct.NodeList* %l1, i8* %tmp)
  %triangle = call i32 @system(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @str, i32 0, i32 0))
  %l4 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp5 = call i8* @index_acess(%struct.NodeList* %l4, i32 0)
  %tmp6 = call i32 @pointer_to_int(i8* %tmp5)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp6)
>>>>>>> ba1aa67b5d1bcf8330ade6f5a31a4959f0fb96e1
  ret i32 0
}
