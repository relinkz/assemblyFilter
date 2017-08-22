section .text
	global _start

_start:

	;call openFileIn			;open the org image
	;call readFromFileIn		;read the data
	;call closeFileIn		;close file

	;call openFileOut		;open output file
	;call writeToFile		;write the data in data
	;call closeFileOut		;close file

	call conditionalTest
	call exitProg			;exit process

openFileIn:
	;opening the file roller1.raw
	MOV eax, 5
	MOV ebx, fileName
	MOV edx, 0777
	int 0x80

	MOV [fd_in], eax	;get pointer to indexbuffer
	ret

openFileOut:
 	;opening the file roller1.raw
	MOV eax, 5
	MOV ebx, outName
	MOV edx, 0777
	int 0x80

	MOV [fd_out], eax	;get pointer to indexbuffer
	ret

writeToFile:
	;1. Put sys_write(), 4, in EAX
	;2. Put fileDesc in EBX
	;3. Put the pointer to data in ECX
	;4. Put buffer size of data in EDX
	;5. call kernel

	;returns the actual nr of bytes written in EAX

	MOV eax, 4
	MOV ebx, [fd_out]
	MOV ecx, info
	MOV edx, IMAGE_SIZE
	int 0x80
	ret

readFromFileIn:
	;Process: Read from file
	;1. put the system call sys_read() number 3 in EAX
	;2. Put the file descriptor in the EBX register
	;3. Put the pointer to the input buffer in the ECX register
	;4. Put the buffer size, in EDX
	;5. call kernel


	;the system call returns the number of bytes rad in the EAX
	;register, in case of error code is in the EAX register

	;read the file
	MOV eax, 3
	MOV ebx, [fd_in]    ;pointer to inputBuffer
	MOV ecx, info		;buffer size
	MOV edx, IMAGE_SIZE
	int 0x80

	ret

readFromFileOut:
	;Process: Read from file
	;1. put the system call sys_read() number 3 in EAX
	;2. Put the file descriptor in the EBX register
	;3. Put the pointer to the input buffer in the ECX register
	;4. Put the buffer size, in EDX
	;5. call kernel


	;the system call returns the number of bytes rad in the EAX
	;register, in case of error code is in the EAX register

	;read the file
	MOV eax, 3
	MOV ebx, [fd_in]    ;pointer to inputBuffer
	MOV ecx, info		;buffer size
	MOV edx, IMAGE_SIZE
	int 0x80

	ret

printBuffer:
	;1. put syscall sys_write to EAX
	;2. put an argument in EBX
	;3. put the data into ECX
	;4. put the size of the segment in EDX
	;5. call kernel 
   	MOV eax, 4
   	MOV ebx, 1
   	MOV ecx, info
   	MOV edx, IMAGE_SIZE

   	int 0x80
   	ret

closeFileIn:
	;Closing a file
	;1.Put the system call sys_close(), 6, in the EAX register
	;2.Put the file descriptor in the EBX register
	MOV EAX, 6
	MOV EBX, [fd_in]
	int 80h

	;the system call returns error code in eax
	ret

closeFileOut:
	;Closing a file
	;1.Put the system call sys_close(), 6, in the EAX register
	;2.Put the file descriptor in the EBX register
	MOV EAX, 6
	MOV EBX, [fd_out]
	int 80h

	ret

conditionalTest:
	MOV dx, 00 		;set dx to 00
	CMP dx, 00 		;Compare dx with 00
	JE	printYay	;If yes, then jump to printYay

	ret


printYay:
	;output the message
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, yayString
	MOV edx, yayStringLen
	int 0x80
	
	ret

exitProg:
	;call system exit
	mov eax, 1
	int 0x80


section .data
fileName db 'roller1.raw', 0 ;glöm förfan inte nollan
outName db 'roller2.raw', 0
IMAGE_SIZE equ 64256

yayString db 'Yay', 0
yayStringLen equ $-yayString

section .bss
fd_out resb 1
fd_in resb 1
info resb 64256
