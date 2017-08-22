section .text
	global _start

_start:

	call openFileIn			;open the org image
	call readFromFileIn		;read the data
	call closeFileIn		;close file

	call openFileOut		;open output file
	call writeToFile		;write the data in data
	call closeFileOut		;close file

	call exitProg			;exit process

openFileIn:
 	;opening the file roller1.raw
	mov eax, 5
	mov ebx, fileName
	mov edx, 0777
	int 0x80

	mov [fd_in], eax	;get pointer to indexbuffer
	ret

openFileOut:
 	;opening the file roller1.raw
	mov eax, 5
	mov ebx, outName
	;mov ecx, 1
	mov edx, 0777
	int 0x80

	mov [fd_out], eax	;get pointer to indexbuffer
	ret

writeToFile:
	;1. Put sys_write(), 4, in EAX
	;2. Put fileDesc in EBX
	;3. Put the pointer to data in ECX
	;4. Put buffer size of data in EDX
	;5. call kernel

	;returns the actual nr of bytes written in EAX

	mov eax, 4
	mov ebx, [fd_out]
	mov ecx, info
	mov edx, IMAGE_SIZE
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
	mov eax, 3
	mov ebx, [fd_in]    ;pointer to inputBuffer
	mov ecx, info		;buffer size
	mov edx, IMAGE_SIZE
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
	mov eax, 3
	mov ebx, [fd_in]    ;pointer to inputBuffer
	mov ecx, info		;buffer size
	mov edx, IMAGE_SIZE
	int 0x80

	ret

printBuffer:
	;1. put syscall sys_write to EAX
	;2. put an argument in EBX
	;3. put the data into ECX
	;4. put the size of the segment in EDX
	;5. call kernel 
   	mov eax, 4
   	mov ebx, 1
   	mov ecx, info
   	mov edx, IMAGE_SIZE
   	
   	int 0x80
   	ret

closeFileIn:
	;Closing a file
	;1.Put the system call sys_close(), 6, in the EAX register
	;2.Put the file descriptor in the EBX register
	mov EAX, 6
	mov EBX, [fd_in]
	int 80h

	;the system call returns error code in eax
	ret

closeFileOut:
	;Closing a file
	;1.Put the system call sys_close(), 6, in the EAX register
	;2.Put the file descriptor in the EBX register
	mov EAX, 6
	mov EBX, [fd_out]
	int 80h

	ret

exitProg:
	;call system exit
	mov eax, 1
	int 0x80

section .data
fileName db 'roller1.raw', 0 ;glöm förfan inte nollan
;lenfFileName equ $-fileName ; adress
outName db 'roller2.raw', 0
;lenOutName equ $-fileName
IMAGE_SIZE equ 64256

section .bss
fd_out resb 1
fd_in resb 1
info resb 64256
