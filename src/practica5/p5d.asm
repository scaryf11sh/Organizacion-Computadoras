%include "../../lib/pc_io.inc"

section	.data
    msg	db  'abcdefghijklmnopqrstuvwxyz0123456789',0xa,0 

section	.text
	global _start
	
_start:                   
	mov edx, msg
	call puts

    mov ebx, msg
    mov eax, 25
    mov byte [ebx + eax], 'Z'

    mov edx, msg
    call puts

	mov	eax, 1
	int	0x80
