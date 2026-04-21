build:
	nasm -f elf32 main.asm
	nasm -f elf32 -o ../../lib/capturar.o ../../lib/capturar.asm
	ld -m elf_i386 main.o ../../lib/capturar.o -o ../../bin/practica7.exe ../../lib/libpc_io.a ../../lib/int.o
run:
	./../../bin/practica7.exe
