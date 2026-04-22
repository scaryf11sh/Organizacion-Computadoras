%include "../../lib/pc_io.inc"
	extern capturar

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

	; el mismo buffer cadena se reutiliza para ambas conversiones;
	; minusculas/mayusculas trabajan in-place asi que no se necesita buffer extra
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
	call mayusculas    ; opera sobre la cadena ya convertida a minusculas; garantiza todo mayusculas
	call puts

	mov  al, 0xa
	call putchar

	mov eax, 1
	int 0x80

	; mayusculas: edx = inicio cadena, convierte a-z -> A-Z in-place

mayusculas:
	push eax   ; convencion de registro: no tenemos frame, guardamos lo que el caller podria necesitar
	push edx   ; edx es el puntero que avanzamos; al retornar debe estar donde el caller lo dejo

.ciclo:
	mov al, [edx]
	cmp al, 0
	je  .salir
	cmp al, 'a'
	jb  .siguiente
	cmp al, 'z'
	ja  .siguiente     ; los rangos 'a'-'z' y 'A'-'Z' son contiguos en ASCII, basta un rango
	sub al, 32         ; distancia entre mayuscula y minuscula en ASCII es exactamente 32 (0x20)
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
	add al, 32         ; mismo offset que mayusculas pero en sentido contrario
	mov [edx], al

.siguiente:
	inc edx
	jmp .ciclo

.salir:
	pop edx
	pop eax
	ret
