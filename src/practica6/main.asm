%include "../../lib/pc_io.inc"

section .data
msg_prompt  db 'Ingresa cadena: ', 0
msg_minus   db 'Minusculas: ', 0
msg_mayus   db 'Mayusculas: ', 0
cadena  times 64 db 0

section .text
global  _start

_start:
	mov  edx, msg_prompt
	call puts

	mov  ax, 64
	mov  edx, cadena
	call capturar

	; capturar ya echo el Enter, cursor ya esta en nueva linea

	mov  edx, msg_minus
	call puts
	mov  edx, cadena
	call minusculas
	call puts

	mov  al, 0xa
	call putchar

	mov  edx, msg_mayus
	call puts
	mov  edx, cadena
	call mayusculas
	call puts

	mov  al, 0xa
	call putchar

	mov eax, 1
	int 0x80

	; capturar: edx = buffer destino, ax = max chars (incluye nulo)

capturar:
	push  ebx
	push  ecx
	movzx ecx, ax
	dec   ecx; reservar 1 para nulo
	mov   ebx, edx; ebx = inicio del buffer

.ciclo:
	call getch
	cmp  al, 127
	jne  .guardar

	;    backspace: solo si hay caracteres capturados
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

	; mayusculas: edx = inicio cadena, convierte a-z -> A-Z in-place

mayusculas:
	push eax
	push edx

.ciclo:
	mov al, [edx]
	cmp al, 0
	je  .salir
	cmp al, 'a'
	jb  .siguiente
	cmp al, 'z'
	ja  .siguiente
	sub al, 32
	mov [edx], al

.siguiente:
	inc edx
	jmp .ciclo

.salir:
	pop edx
	pop eax
	ret

	; minusculas: edx = inicio cadena, convierte A-Z -> a-z in-place

minusculas:
	push eax
	push edx

.ciclo:
	mov al, [edx]
	cmp al, 0
	je  .salir
	cmp al, 'A'
	jb  .siguiente
	cmp al, 'Z'
	ja  .siguiente
	add al, 32
	mov [edx], al

.siguiente:
	inc edx
	jmp .ciclo

.salir:
	pop edx
	pop eax
	ret
