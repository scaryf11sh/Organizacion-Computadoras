sudo apt update
sudo apt install nasm

nasm -f elf64 src\suma.asm -o src\suma.o