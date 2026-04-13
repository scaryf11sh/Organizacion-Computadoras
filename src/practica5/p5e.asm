%include "../../lib/pc_io.inc"

section	.data
    msg	db  'abcdefghijklmnopqrstuvwxyz0123456789',0xa,0 

section	.text
	global _start
	
_start:                   
	mov edx, msg        
    call puts           

    mov ebx, msg
    mov esi, 10
    mov byte [ebx + esi + 5], 'P' ; 10 + 5 = 15

    mov edx, msg
    call puts

	mov	eax, 1
	int	0x80
