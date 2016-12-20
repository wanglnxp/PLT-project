; ModuleID = 'firstOpengl.c'
source_filename = "firstOpengl.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12.0"

%struct.GLFWwindow = type opaque
%struct.GLFWmonitor = type opaque

@.str = private unnamed_addr constant [12 x i8] c"Hello World\00", align 1

; Function Attrs: nounwind ssp uwtable
define i32 @draw(i32) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca %struct.GLFWwindow*, align 8
  store i32 %0, i32* %3, align 4
  %5 = call i32 @glfwInit()
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %8, label %7

; <label>:7                                       ; preds = %1
  store i32 -1, i32* %2, align 4
  br label %23

; <label>:8                                       ; preds = %1
  %9 = call %struct.GLFWwindow* @glfwCreateWindow(i32 480, i32 320, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i32 0, i32 0), %struct.GLFWmonitor* null, %struct.GLFWwindow* null)
  store %struct.GLFWwindow* %9, %struct.GLFWwindow** %4, align 8
  %10 = load %struct.GLFWwindow*, %struct.GLFWwindow** %4, align 8
  %11 = icmp ne %struct.GLFWwindow* %10, null
  br i1 %11, label %13, label %12

; <label>:12                                      ; preds = %8
  call void @glfwTerminate()
  store i32 -1, i32* %2, align 4
  br label %23

; <label>:13                                      ; preds = %8
  %14 = load %struct.GLFWwindow*, %struct.GLFWwindow** %4, align 8
  call void @glfwMakeContextCurrent(%struct.GLFWwindow* %14)
  br label %15

; <label>:15                                      ; preds = %20, %13
  %16 = load %struct.GLFWwindow*, %struct.GLFWwindow** %4, align 8
  %17 = call i32 @glfwWindowShouldClose(%struct.GLFWwindow* %16)
  %18 = icmp ne i32 %17, 0
  %19 = xor i1 %18, true
  br i1 %19, label %20, label %22

; <label>:20                                      ; preds = %15
  call void @glClear(i32 16384)
  call void @glBegin(i32 4)
  call void @glColor3f(float 1.000000e+00, float 0.000000e+00, float 0.000000e+00)
  call void @glVertex3f(float 0.000000e+00, float 1.000000e+00, float 0.000000e+00)
  call void @glColor3f(float 0.000000e+00, float 1.000000e+00, float 0.000000e+00)
  call void @glVertex3f(float -1.000000e+00, float -1.000000e+00, float 0.000000e+00)
  call void @glColor3f(float 0.000000e+00, float 0.000000e+00, float 1.000000e+00)
  call void @glVertex3f(float 1.000000e+00, float -1.000000e+00, float 0.000000e+00)
  call void @glEnd()
  %21 = load %struct.GLFWwindow*, %struct.GLFWwindow** %4, align 8
  call void @glfwSwapBuffers(%struct.GLFWwindow* %21)
  call void @glfwPollEvents()
  br label %15

; <label>:22                                      ; preds = %15
  store i32 0, i32* %2, align 4
  br label %23

; <label>:23                                      ; preds = %22, %12, %7
  %24 = load i32, i32* %2, align 4
  ret i32 %24
}

declare i32 @glfwInit() #1

declare %struct.GLFWwindow* @glfwCreateWindow(i32, i32, i8*, %struct.GLFWmonitor*, %struct.GLFWwindow*) #1

declare void @glfwTerminate() #1

declare void @glfwMakeContextCurrent(%struct.GLFWwindow*) #1

declare i32 @glfwWindowShouldClose(%struct.GLFWwindow*) #1

declare void @glClear(i32) #1

declare void @glBegin(i32) #1

declare void @glColor3f(float, float, float) #1

declare void @glVertex3f(float, float, float) #1

declare void @glEnd() #1

declare void @glfwSwapBuffers(%struct.GLFWwindow*) #1

declare void @glfwPollEvents() #1

attributes #0 = { nounwind ssp uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"PIC Level", i32 2}
!1 = !{!"Apple LLVM version 8.0.0 (clang-800.0.42.1)"}
