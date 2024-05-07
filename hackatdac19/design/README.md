# Hack@DAC 2019

Alpha Stage SoC Simulation Setup 
SoC simulation setup is done in three stages.
* Stage 1: Download all the required files
* Stage 2: Set up the RISC-V toolchain
* Stage 3: Set up the Ariane SoC

## Download all the required files: 
1. To make sure that you have everything in one place, create a new directory, say “hackdac_alpha”. This directory will be called as the root directory through out the rest of this document 
```
Mkdir hackdac_alpha 
```
2. Download the [RISC-V tools](https://drive.google.com/drive/folders/1QH6BuNU2eiIv19rBtn7zWPXdTk3HRXlN?usp=s), [fesvr_source](https://drive.google.com/drive/folders/1QH6BuNU2eiIv19rBtn7zWPXdTk3HRXlN), and Checkout the repository of the hackdac_2019
```
$ git clone https://github.com/HACK-EVENT/hackatdac19.git
$ git submodule update --init --recursive
```

## Setting up the toolchain : 
3. Unzip the toolchain source folder in the root directory, this should create a folder called ```toolchain_source```
  + unzip ```toolchain_source.zip```
4. Install dependencies for building the toolchain 
  + For Ubuntu-based systems: 
```
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev 
```
  + For Fedora-based systems: 
```
sudo dnf install autoconf automake @development-tools curl dtc libmpc-devel mpfr-devel gmp-devel libusb-devel gawk gcc-c++ bison flex texinfo gperf libtool patchutils bc zlib-devel expat-devel
```
5. Create a directory to install the toolchain in the root directory and setup a variable named 
“RISCV” that points to the location 
```
  mkdir riscv-tools 
  export RISCV=<path_to_root_directory/riscv-tools> 
  cd toolchain_source 
  ./build.sh 
  cd ../ 
```
6. Add the riscv tool binaries to the path list. 
```
export PATH=$RISCV/bin:$PATH 
```
7. To generate ```.elf``` files, create the C source code you want to run in the “software” sub-directory in the “toolchain_source” directory. Update and run the the Makefile present there accordingly. For example, to generate the ```.elf``` for ```hello_world.c```: 
```
cd software
mkdir hello_world
echo 'int main(int argc, char** argv) {printf("Hello World\n"); return 0; } ' > hello_world/hello_world.c
sed -i 's/dhrystone/dhrystone hello_world /g' Makefile
make all 
```
This will generate the “hello_world.riscv” elf file. 
## Notes
* This should install the RISCV toolchain in your system. 
* If step 5 gives you errors, try to install all the dependencies listed in step 4. 
* If you do not have sudo access to install the dependencies, then the toolchain has to be installed on some other system where you have sudo access. (For example, in a virtual machine). 
* If you are installing the toolchain on one system (e.g., Ubuntu) with sudo access and want to run the SoC simulation in another system (e.g., CENTOS) without sudo access, then do the following (otherwise ignore these steps) : 
* Install the RISCV toolchain on the Ubuntu system following the above steps 1 to 7. You will then use this to generate your elf files. 
* Create the root directory “hackdac_alpha” in CENTOS as well, and copy the “riscv-tools” directory from LINUX system to the CENTOS system’s root directory 
* Do the steps 5.b and 6.a in the CENTOS.
* Install the fesvr tool : 
```
unzip fesvr_source.zip
cd riscv-fesvr
mkdir build 
cd build 
../configure --prefix=$RISCV --target=riscv64-unknown-elf
make install
cd ../../ 
```
* The toolchain does not work this way in your CENTOS system, but we can still manage to run the SoC. 
* Create a dummy “software” directory in the root directory of your CENTOS system and copy the elf files generated in the LINUX system to this directory. 

## Setting up the Ariane SoC
8. Unzip the SoC in the root directory, this should create a directory named “ariane” 
```
unzip ariane.zip
```
9. In ariane/Makefile file, after line 75, you might have to include the Modelsim library file path with the appropriate path for your system (it will be ```<modelsim tool installation>/includes``` directory) with a ```-I``` prefix. Depending on your system, it might work without including this path. See the commented line 76 for reference. 
10. Source the Modelsim/Questasim license file. See example below. 
```
source /opt/coe/mentorgraphics/modelsim/setup.modelsim.bash 
```
11. Export RISCV and add riscv-tools binaries to the path list. 
```
export RISCV=<path_to_root_directory/riscv-tools> 
export PATH=$RISCV/bin:$PATH
```

12. Copy the elf file generated from the step 6 into the ariane directory. (You can also use 
the ```hello.elf``` file that is present in the ```ariane``` directory or ```ariane/elf_files``` directory) 
```
cp -r ../software/<elf_name>.riscv . 
```
13. Run the simulation 
```
make sim elf-bin=<elf_name>.riscv 
```

## Support & Questions

For any issues with the SoC or any questions you can refer to [Hack@Event](https://hackatevent.org) website.
