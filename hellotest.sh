# Hello World
make
read -p "Let's see some Hello World action. Please any key to continue."

echo "Result:"
echo

clang -S -emit-llvm ./list.c
./microc.native < hello.mc > demo.ll
/usr/local/opt/llvm/bin/llvm-link demo.ll list.ll -o a.out
/usr/local/opt/llvm/bin/lli a.out


# MAYBE ANOTHER DEMO HERE? 

echo

make clean
echo "Thanks for watching!" 