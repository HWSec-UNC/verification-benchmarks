#!/bin/bash
# Run this to create a pk that includes and runs the user progeram elf from the
# software dir.

rm -rf build
mkdir build
cp ../software/user_program.elf build/helloworld
cd build
export temp_cc=$CC
export CC=
export PATH=${PITON_ROOT}/../tools/riscv_gcc/bin:$PATH
../configure --prefix=$RISCV --host=riscv64-unknown-elf
export CC=$temp_cc
make -j $(nproc)
cd ../
