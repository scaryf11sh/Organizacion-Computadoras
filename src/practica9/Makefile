
build:
	gcc -Wall -Werror -pedantic -std=c99 -m32 -c main.c
	nasm -f elf32 functions.asm
	gcc -m32 functions.o main.o -L ../../lib -lpc_io -no-pie -z noexecstack -o ../../bin/practica10.exe  

run:
	../../bin/practica10.exe
