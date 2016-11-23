# Hello World
make
read -p "Let's see some Hello World action. Please any key to continue."

echo "Result:"
echo

./microc.native < hello.mc > demo.ll
/usr/local/opt/llvm/bin/lli demo.ll


# MAYBE ANOTHER DEMO HERE? 

echo

make clean
echo "Thanks for watching!" 