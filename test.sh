# Hello World

make
var=$1
echo $var

read -p "Let's see some Hello World action. Please any key to continue."

echo "Result:"
echo


clang -emit-llvm -o list.bc -c src/list.c
clang -emit-llvm -I/usr/local/include/ -I/usr/local/lib/framework/OpenGL -I/usr/local/lib/lglfw -o firstOpengl.bc -c firstOpengl.c
# clang -S -emit-llvm ./list.c
./egrapher.native < $1 > demo.ll
/usr/local/opt/llvm/bin/llvm-link demo.ll list.bc firstOpengl.bc -o a.out,
/usr/local/opt/llvm/bin/lli a.out


# MAYBE ANOTHER DEMO HERE? 

echo

make clean
echo "Thanks for watching!" 