; Vdecl a
;false
;  %tmp = call i32 @length(%struct.NodeList* %l)
;tmp
;false
;  %tmp4 = call i32 @length(%struct.NodeList* %l3)
;tmp4
;false
;  %tmp9 = call i32 @length(%struct.NodeList* %l8)
;tmp9
; print
; print
; binopi32 0
; i32
; Vdecl xxx
; print
; binopi32 9
; i32
; print
; Return
; ModuleID = 'MicroC'

%struct.NodeList = type { %struct.ListNode* }
%struct.ListNode = type { i8*, %struct.ListNode* }
%person = type <{ i32, i32 }>

@l = global %struct.NodeList* null
@n = global %struct.NodeList* null
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [12 x i8] c"hello world\00"

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
  %xxx = alloca i32
  %a = alloca %person
  %age = getelementptr inbounds %person, %person* %a, i32 0, i32 1
  store i32 10, i32* %age
  %l = load %struct.NodeList*, %struct.NodeList** @l
  %tmp = call i32 @length(%struct.NodeList* %l)
  %init = call %struct.NodeList* @init_List()
  %tmp1 = call i8* @int_to_pointer(i32 2733)
  %tmp2 = call %struct.NodeList* @add_back(%struct.NodeList* %init, i8* %tmp1)
  store %struct.NodeList* %tmp2, %struct.NodeList** @l
  %l3 = load %struct.NodeList*, %struct.NodeList** @l
  %tmp4 = call i32 @length(%struct.NodeList* %l3)
  %init5 = call %struct.NodeList* @init_List()
  %tmp6 = call i8* @int_to_pointer(i32 444)
  %tmp7 = call %struct.NodeList* @add_back(%struct.NodeList* %init5, i8* %tmp6)
  store %struct.NodeList* %tmp7, %struct.NodeList** @l
  %l8 = load %struct.NodeList*, %struct.NodeList** @l
  %tmp9 = call i32 @length(%struct.NodeList* %l8)
  %init10 = call %struct.NodeList* @init_List()
  %tmp11 = call i8* @int_to_pointer(i32 1234)
  %tmp12 = call %struct.NodeList* @add_back(%struct.NodeList* %init10, i8* %tmp11)
  store %struct.NodeList* %tmp12, %struct.NodeList** @l
  %l13 = load %struct.NodeList*, %struct.NodeList** @l
  %tmp14 = call i8* @index_acess(%struct.NodeList* %l13, i32 0)
  %tmp15 = call i32 @pointer_to_int(i8* %tmp14)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %tmp15)
  %print_bool = call i32 @print_bool(i32 -1)
  store i32 9, i32* %xxx
  %xxx16 = load i32, i32* %xxx
  %tmp17 = icmp eq i32 %xxx16, 9
  %x = sitofp i1 %tmp17 to double
  %x2 = fptosi double %x to i32
  %print_bool18 = call i32 @print_bool(i32 %x2)
  %printf19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.3, i32 0, i32 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str, i32 0, i32 0))
  ret i32 0
}
