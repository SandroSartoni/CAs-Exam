x64 Settings
=========
These files have been tested on Linux OS, in particular Ubuntu. It's necessary to download only NASM, by simply typing:
```
sudo apt-get install nasm
```
Once the installation has completed and once we've moved in the same directory of the assembly files, it's necessary to type in the terminal:
```
nasm -f elf64 -o filename.o filename.asm
ld -o filename filename.o 
```
provided that, instead of filename, there's the actual name of the source code. If there're no errors, in order to run the executable, the command is: `./filename` 
