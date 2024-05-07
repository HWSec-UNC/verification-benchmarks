user_prog=$1
echo running user program: $1.c
cd ../software
export PATH=${PITON_ROOT}/../tools/riscv_gcc/bin:$PATH
riscv64-unknown-elf-gcc -fno-builtin-printf ariane_api.c syscalls.c $1.c -o user_program.elf
cd ../pk
./make_embedded.bash
cp build/pk ../build/diag.exe
cd ../build
rv64_img
cd $PITON_ROOT/build
