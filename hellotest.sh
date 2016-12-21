# Hello World

var=$1

echo "Result:"
echo

clang -emit-llvm -o list.bc -c src/list.c
# clang -S -emit-llvm ./list.c
./egrapher.native < $1 > demo.ll
/usr/local/opt/llvm/bin/llvm-link demo.ll list.bc -o a.out
/usr/local/opt/llvm/bin/lli a.out


# MAYBE ANOTHER DEMO HERE? 

echo
