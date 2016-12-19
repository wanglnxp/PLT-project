# Hello World
make
read -p "Let's see some Hello World action. Please any key to continue."

echo "Result:"
echo

#clang -S -emit-llvm ./list.c
./egrapher.native < hello.eg > demo.ll
/usr/local/opt/llvm38/bin/llvm-link-3.8 demo.ll -o a.out
/usr/local/opt/llvm38/bin/lli-3.8 a.out


# MAYBE ANOTHER DEMO HERE? 

echo

make clean
echo "Thanks for watching!" 
