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
	mov edx, 250 + 250
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

	mov [blurr], al 		 ;save value to blurr

	;[o][x][o] r1
	;[o][o][o] r2

	mov ecx, 1					;ecx is the iterator

	call firstRow				;loop through all upper pixels

	;last pixel in row
	;[o][x]
	;[o][o]

	mov [sum], word 0			;reset sum

	mov al, byte [info + 249]	;add top left pixel
	movzx ax, al 				;convert byte to word

	add [sum], ax 				;add value to sum

	mov al, byte [info + 250]	;add the processing pixel
	movzx ax, al 				;convert byte to word

	add [sum], ax   			;add to sum

	mov al, byte [info + 249 + 251] ;bot left pixel
	movzx ax, al 					;convert byte to word

	add [sum], ax

	mov al, byte [info + 250 + 251] ;bot pixel
	movzx ax, al

	add [sum], ax 				;add to sum

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 4 	 				 ;Divition by 4
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition

	mov [blurr + 250], al 		 ;save value to blurr

	mov cl, 251					 ;cl holds the offset
	movzx cx, cl
	movzx ecx, cx

	mov al, 250 					;offset for rows
	movzx ax, al 					;convert to word

	mov [offset], al 				;throw it in to the offset


	;move on to the next rows
	call middleRow


	ret

middleRow:
	
	;row 1 to 255 will take 9 pixels as average

	;[o][o]
	;[x][o]
	;[o][o]

	mov al, byte [info + ecx - 251] ; pixel above
	movzx ax, al

	mov [sum], ax

	mov al, byte [info + ecx - 250] ; top right pixel
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx] 		;the pixel itself
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 1] 	;mid right pixel
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 251] ;pixel bottom 
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 252]  ;bot right pixel
	movzx ax, al

	add [sum], ax

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 6 	 				 ;Divition by 4
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition


	mov [blurr + ecx], al

	inc ecx 			;first pixel done


	;[o][o][o]
	;[o][x][o]
	;[o][o][o]

	call middleLoop

	;[o][o]
	;[o][x]
	;[o][o]

	mov [sum], word 0			;reset sum

	mov al, byte [info + ecx - 250 - 1] 	;top-teft pixel
	movzx ax, al 						;convert byte to word

	add [sum], ax 					;add value to sum

	mov al, byte [info + ecx - 250]	;top pixel
	movzx ax, al 					;convert byte to word

	add [sum], ax   				;add to sum

	mov al, byte [info + ecx - 1] 	;mid-left pixel
	movzx ax, al 					;convert byte to word

	add [sum], ax 					;add to sum

	mov al, byte [info + ecx] 		;Processing pixel
	movzx ax, al

	add [sum], ax 					;add to sum

	mov al, byte [info + ecx + 250] ;bot left
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 251] ;pixel bottom 
	movzx ax, al

	add [sum], ax

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 4 	 				 ;Divition by 4
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition

	mov [blurr + ecx], al 		 ;save value to blurr
	inc ecx

	;mov [blurr + ecx], byte 0xFF 		 ;save value to blurr

	;row done

	;mov ax, 63750
	;cmp cx, ax
	;jl middleRow

	ret

middleLoop:


	mov [sum], word 0

	mov al, byte [info + ecx - 250] ; top left
	movzx ax, al

	mov [sum], ax

	mov al, byte [info + ecx - 251] ; pixel above
	movzx ax, al

	mov [sum], ax

	mov al, byte [info + ecx - 250] ; top right pixel
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx -1] 		;mid left
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx] 		;the pixel itself
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 1] 	;mid right pixel
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 250] ;bot left
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 251] ;pixel bottom 
	movzx ax, al

	add [sum], ax

	mov al, byte [info + ecx + 252]  ;bot right pixel
	movzx ax, al

	add [sum], ax

	mov ax, [sum] 				 ;prep sum for divition
	movzx eax, ax 				 ;convert word to full 32-bit register

	mov ebp, 9 	 				 ;Divition by 9
	mov edx, 0 					 ;how many rest products that are stored
	div ebp 					 ;call divition


	mov [blurr + ecx], byte al
	inc ecx
	
	mov eax, ecx

	mov [blurr + 495], byte ch
	mov [blurr + 496], byte cl

	mov ax, word [offset]

	mov [blurr + 498], byte ah
	mov [blurr + 499], byte al

	sub cx, word [offset]
	;movzx ecx, cx
	 						;ecx is x iterator
	
	mov al, 250
	movzx ax, al

	cmp cx, ax
	jl middleLoop

	;the middle loop is done, save to offset
	add [offset], cx

	movzx ecx, cx
	mov ecx, eax

	;mov eax, ecx

	;mov ebp, 250
	;mov edx, 1
	;div ebp

	;cmp edx, 0 				;ecx % 500, modulu
	;jnz middleRow

	ret

firstRow:

	;loop here

	;reset sum
	mov [sum], word 0
	
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

	inc ecx 						;ecx is iterator
	cmp ecx, 250
	jl firstRow

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
	mov EAX, 4
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
offset resw 1