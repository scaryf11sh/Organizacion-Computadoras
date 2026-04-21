	extern getch
	extern putchar

	global capturar

	section .text

; capturar: edx = buffer destino, ax = max chars (incluye nulo)
capturar:
	push  ebx
	push  ecx
	movzx ecx, ax
	dec   ecx
	mov   ebx, edx

.ciclo:
	call getch
	cmp  al, 127
	jne  .guardar

	cmp  edx, ebx
	je   .ciclo
	dec  edx
	inc  ecx
	call borrar
	jmp  .ciclo

.guardar:
	call putchar
	mov  [edx], al
	cmp  al, 0xa
	je   .salir
	inc  edx
	loop .ciclo

.salir:
	mov byte [edx], 0
	pop ecx
	pop ebx
	ret

borrar:
	push eax
	mov  al, 0x8
	call putchar
	mov  al, ' '
	call putchar
	mov  al, 0x8
	call putchar
	pop  eax
	ret
