; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; int
; ModuleID = 'eGrapher'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }

@l = global %struct.NodeList* null
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.8 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.9 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.10 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.11 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.12 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.13 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.14 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.15 = private unnamed_addr constant [4 x i8] c"%s\0A\00"

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

define void @swap(%struct.NodeList* %l, i32 %i, i32 %k) {
entry:
  %l1 = alloca %struct.NodeList*
  store %struct.NodeList* %l, %struct.NodeList** %l1
  %i2 = alloca i32
  store i32 %i, i32* %i2
  %k3 = alloca i32
  store i32 %k, i32* %k3
  %temp = alloca i32
  %l4 = load %struct.NodeList*, %struct.NodeList** %l1
  %i5 = load i32, i32* %i2
  %tmp = call i8* @index_acess(%struct.NodeList* %l4, i32 %i5)
  %tmp6 = call i32 @pointer_to_int(i8* %tmp)
  store i32 %tmp6, i32* %temp
  %l7 = load %struct.NodeList*, %struct.NodeList** %l1
  %l8 = load %struct.NodeList*, %struct.NodeList** %l1
  %k9 = load i32, i32* %k3
  %tmp10 = call i8* @index_acess(%struct.NodeList* %l8, i32 %k9)
  %tmp11 = call i32 @pointer_to_int(i8* %tmp10)
  %tmp12 = call i8* @int_to_pointer(i32 %tmp11)
  %tmp13 = call i32 @node_change(%struct.NodeList* %l7, i32 0, i8* %tmp12)
  %l14 = load %struct.NodeList*, %struct.NodeList** %l1
  %k15 = load i32, i32* %k3
  %temp16 = load i32, i32* %temp
  %tmp17 = call i8* @int_to_pointer(i32 %temp16)
  %tmp18 = call i32 @node_change(%struct.NodeList* %l14, i32 %k15, i8* %tmp17)
  ret void
}

define i32 @partition(%struct.NodeList* %l, i32 %left, i32 %right) {
entry:
  %l1 = alloca %struct.NodeList*
  store %struct.NodeList* %l, %struct.NodeList** %l1
  %left2 = alloca i32
  store i32 %left, i32* %left2
  %right3 = alloca i32
  store i32 %right, i32* %right3
  %i = alloca i32
  %pivot = alloca i32
  %storeIndex = alloca i32
  %left4 = load i32, i32* %left2
  store i32 %left4, i32* %storeIndex
  %l5 = load %struct.NodeList*, %struct.NodeList** %l1
  %right6 = load i32, i32* %right3
  %tmp = call i8* @index_acess(%struct.NodeList* %l5, i32 %right6)
  %tmp7 = call i32 @pointer_to_int(i8* %tmp)
  store i32 %tmp7, i32* %pivot
  %left8 = load i32, i32* %left2
  store i32 %left8, i32* %i
  br label %while

while:                                            ; preds = %merge, %entry
  %i22 = load i32, i32* %i
  %right23 = load i32, i32* %right3
  %tmp24 = icmp slt i32 %i22, %right23
  br i1 %tmp24, label %while_body, label %merge25

while_body:                                       ; preds = %while
  %l9 = load %struct.NodeList*, %struct.NodeList** %l1
  %i10 = load i32, i32* %i
  %tmp11 = call i8* @index_acess(%struct.NodeList* %l9, i32 %i10)
  %tmp12 = call i32 @pointer_to_int(i8* %tmp11)
  %pivot13 = load i32, i32* %pivot
  %tmp14 = icmp slt i32 %tmp12, %pivot13
  br i1 %tmp14, label %then, label %else

merge:                                            ; preds = %else, %then
  %i20 = load i32, i32* %i
  %tmp21 = add i32 %i20, 1
  store i32 %tmp21, i32* %i
  br label %while

then:                                             ; preds = %while_body
  %i15 = load i32, i32* %i
  %storeIndex16 = load i32, i32* %storeIndex
  %l17 = load %struct.NodeList*, %struct.NodeList** %l1
  call void @swap(%struct.NodeList* %l17, i32 %storeIndex16, i32 %i15)
  %storeIndex18 = load i32, i32* %storeIndex
  %tmp19 = add i32 %storeIndex18, 1
  store i32 %tmp19, i32* %storeIndex
  br label %merge

else:                                             ; preds = %while_body
  br label %merge

merge25:                                          ; preds = %while
  %storeIndex26 = load i32, i32* %storeIndex
  %right27 = load i32, i32* %right3
  %l28 = load %struct.NodeList*, %struct.NodeList** %l1
  call void @swap(%struct.NodeList* %l28, i32 %right27, i32 %storeIndex26)
  %storeIndex29 = load i32, i32* %storeIndex
  ret i32 %storeIndex29
}

define void @sort(%struct.NodeList* %l, i32 %left, i32 %right) {
entry:
  %l1 = alloca %struct.NodeList*
  store %struct.NodeList* %l, %struct.NodeList** %l1
  %left2 = alloca i32
  store i32 %left, i32* %left2
  %right3 = alloca i32
  store i32 %right, i32* %right3
  %storeIndex = alloca i32
  %left4 = load i32, i32* %left2
  %right5 = load i32, i32* %right3
  %tmp = icmp sgt i32 %left4, %right5
  br i1 %tmp, label %then, label %else

merge:                                            ; preds = %else, %then
  %right6 = load i32, i32* %right3
  %left7 = load i32, i32* %left2
  %l8 = load %struct.NodeList*, %struct.NodeList** %l1
  %partition_result = call i32 @partition(%struct.NodeList* %l8, i32 %left7, i32 %right6)
  store i32 %partition_result, i32* %storeIndex
  %storeIndex9 = load i32, i32* %storeIndex
  %tmp10 = sub i32 %storeIndex9, 1
  %left11 = load i32, i32* %left2
  %l12 = load %struct.NodeList*, %struct.NodeList** %l1
  call void @sort(%struct.NodeList* %l12, i32 %left11, i32 %tmp10)
  %right13 = load i32, i32* %right3
  %storeIndex14 = load i32, i32* %storeIndex
  %tmp15 = add i32 %storeIndex14, 1
  %l16 = load %struct.NodeList*, %struct.NodeList** %l1
  call void @sort(%struct.NodeList* %l16, i32 %tmp15, i32 %right13)
  ret void

then:                                             ; preds = %entry
  br label %merge

else:                                             ; preds = %entry
  br label %merge
}

define i32 @main() {
entry:
  %l = alloca %struct.NodeList*
  %init = call %struct.NodeList* @init_List()
  store %struct.NodeList* %init, %struct.NodeList** %l
  %i = alloca i32
  %l1 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp = call i8* @int_to_pointer(i32 3)
  %tmp2 = call %struct.NodeList* @add_back(%struct.NodeList* %l1, i8* %tmp)
  %l3 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp4 = call i8* @int_to_pointer(i32 2)
  %tmp5 = call %struct.NodeList* @add_back(%struct.NodeList* %l3, i8* %tmp4)
  %l6 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp7 = call i8* @int_to_pointer(i32 5)
  %tmp8 = call %struct.NodeList* @add_back(%struct.NodeList* %l6, i8* %tmp7)
  %l9 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp10 = call i8* @int_to_pointer(i32 4)
  %tmp11 = call %struct.NodeList* @add_back(%struct.NodeList* %l9, i8* %tmp10)
  %l12 = load %struct.NodeList*, %struct.NodeList** %l
  %tmp13 = call i8* @int_to_pointer(i32 1)
  %tmp14 = call %struct.NodeList* @add_back(%struct.NodeList* %l12, i8* %tmp13)
  %l15 = load %struct.NodeList*, %struct.NodeList** %l
  call void @sort(%struct.NodeList* %l15, i32 0, i32 4)
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %while_body, %entry
  %i22 = load i32, i32* %i
  %tmp23 = icmp slt i32 %i22, 5
  br i1 %tmp23, label %while_body, label %merge

while_body:                                       ; preds = %while
  %l16 = load %struct.NodeList*, %struct.NodeList** %l
  %i17 = load i32, i32* %i
  %tmp18 = call i8* @index_acess(%struct.NodeList* %l16, i32 %i17)
  %tmp19 = call i32 @pointer_to_int(i8* %tmp18)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.12, i32 0, i32 0), i32 %tmp19)
  %i20 = load i32, i32* %i
  %tmp21 = add i32 %i20, 1
  store i32 %tmp21, i32* %i
  br label %while

merge:                                            ; preds = %while
  ret i32 0
}
