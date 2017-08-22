# assemblyFilter

Compile assembly file (.asm) with nasm:
nasm -f elf copyImage.asm -o copyImage.o

Use an emulated linker with the structure of an i386 processor
ld -m elf_i386 -s -o copyImage copyImage.o
