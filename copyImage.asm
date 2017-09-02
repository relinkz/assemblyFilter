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
	mov ecx, 0
	int 0x80

	mov [fd_in], eax	;get pointer to indexbuffer
	ret

openFileOut:
 	;opening the file roller1.raw
	mov eax, 5
	mov ebx, outName
	mov ecx, 1
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
	
	;mov ecx, [info + 2]
	;mov [blurr], ecx

	;mov ax, [info + 2]
	;movzx eax, ax
	;mov bx, [info + 3]
	;movzx ebx, bx

	;d6 + d5 = 1AB
	;add eax, ebx
	;mov [blurr], eax

	call blurrTopRow


	;mov eax, 4
	;mov ebx, [fd_out]
	;mov ecx, info
	;mov edx, IMAGE_SIZE
	;int 0x80



	mov eax, 4
	mov ebx, [fd_out]
	mov ecx, blurr
	mov edx, 6
	int 0x80

	ret

blurrTopRow:
	;from 0 - 251 there will be no pixels above the active pixel

	;[x][o]
	;[o][o]
	mov al, byte [info + 0] 	 ;add the pixel itself
	movzx ax, al 		         ;convert byte to word
	
	add [sum], ax 				 ;store sum all pixels in sum

	mov al, byte [info + 1] 	 ;add pixel beside it (1)
	movzx ax, al 				 ;convert from byte to word al->ax

	add [sum], ax 				 ;add to sum

	mov al, byte [info + 251]    ;add the pixels below the first pixel
	movzx ax, al 				 ;convert byte to word

	add [sum], ax 				 ;add to sum

	mov al, byte [info + 252] 	 ;add pixel beside, bot-left
	movzx ax, al 				 ;convert byte to word

	add [sum], ax    			 ;add to sum

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 4 	 				 ;Divition by 7
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition

	mov [blurr + 0], al 		 ;save value to blurr

	;[o][x][o] r1
	;[o][o][o] r2

	mov ecx, 0

	;loop here

	;reset sum
	mov [sum], word 0

	inc ecx 						;ecx is iterator
	
	;first row (r1)

	mov al, byte [info + ecx]		;read pixel i, pixel to blurr
	movzx ax, al 					;convert byte to word

	mov [sum], ax 					;store into sum

	mov al, byte [info + ecx - 1]	;get pixel i-1
	movzx ax, al 					;convert byte to word

	add [sum], ax 					;add to sum

	mov al, byte [info + ecx + 1] 	;get pixel i + 1
	movzx ax, al 					;convert byte to word

	add [sum], ax 					;add to sum

	;Done with the first row
	;second row (r2)

	mov al, byte [info + ecx + 250] ;get pixel i+ 250
	movzx ax, al 					;convert byte to word

	add [sum], ax 					;add to sum

	mov al, byte [info + ecx + 251] ;get pixel i+ 251
	movzx ax, al 					;convert byte to word

	add [sum], ax 					;add to sum

	mov al, byte [info + ecx + 252] ;get pixel i + 252
	movzx ax, al 					;convert byte to word

	add [sum], ax

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 6 	 				 ;Divition by 7
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition

	;second pixel is correctly blurred
	;next up is to do a jump condition that does this to
	;all 250 times, for all upper rows

	mov [blurr + ecx], al

	;mov al, byte [info + 1 - 1]
	;mov [blurr + 0], al

	;mov al, byte [info + 1]
	;mov [blurr + 1], al

	;mov al, byte [info + 1 + 1]
	;mov [blurr + 2], al

	;mov al, byte [info + 1 + 250]
	;mov [blurr + 3], al

	;mov al, byte [info + 1 + 251]
	;mov [blurr + 4], al

	;mov al, byte [info + 1 + 252]
	;mov [blurr + 5], al

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
blurr resb 64256
sum resw 1
activePixel resw 1