# Hello World
make
read -p "Let's see some Hello World action. Please any key to continue."

echo "Result:"
echo

./microc.native < ./testcase11.26/test-var2.eg > demo.ll
/usr/local/opt/llvm/bin/lli demo.ll


# MAYBE ANOTHER DEMO HERE? 

echo

make clean
echo "Thanks for watching!" 