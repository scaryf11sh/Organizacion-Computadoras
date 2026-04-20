%macro FOR 4

.%4_start:
	cmp %1, %2
	jge .%4_end
	%endmacro

	%macro END_FOR 4
	add    %1, %3
	jmp    .%4_start

.%4_end:
	%endmacro

	%include "../../lib/pc_io.inc"

	section .data
	msg_menu_title      db "Seleccione una opcion:", 0xA, 0
	msg_menu_opt_atoi   db "1) atoi", 0xA, 0
	msg_menu_opt_itoa   db "2) itoa", 0xA, 0
	msg_menu_opt_exit   db "3) salir", 0xA, 0
	msg_menu_input      db "--> ", 0
	msg_menu_input_error db "Opcion no valida, intente de nuevo", 0xA, 0
	msg_input_str       db "Ingrese la cadena: ", 0
	msg_input_num       db "Ingrese el numero: ", 0
	msg_res_atoi        db "atoi -> ", 0
	msg_res_itoa        db "itoa -> ", 0

	section .bss
	option  resd 1
	string  resb 32

	section .text
	global  _start

_start:

.menu_while_start:
	mov  edx, msg_menu_title
	call puts
	mov  edx, msg_menu_opt_atoi
	call puts
	mov  edx, msg_menu_opt_itoa
	call puts
	mov  edx, msg_menu_opt_exit
	call puts
	mov  edx, msg_menu_input
	call puts

	call getch
	mov  [option], eax
	call putchar
	mov  al, 0xa
	call putchar

	mov eax, [option]
	cmp al, '1'
	je  .opt_atoi
	cmp al, '2'
	je  .opt_itoa
	cmp al, '3'
	je  .opt_exit
	jmp .opt_error

.opt_atoi:
	mov  edx, msg_input_str
	call puts

	mov  ax, 32
	mov  edx, string
	call capturar

	mov  edx, msg_res_atoi
	call puts

	push dword 32
	push string
	call _atoi
	add  esp, 8

	push string
	push eax
	call _itoa
	add  esp, 8

	mov  edx, string
	call puts
	add  esp, 8

	jmp .menu_while_start

.opt_itoa:
	mov  edx, msg_input_num
	call puts

	mov  ax, 32
	mov  edx, string
	call capturar

	mov  edx, msg_res_itoa
	call puts

	push dword 32
	push string
	call _atoi
	add  esp, 8

	push string
	push eax
	call _itoa
	add  esp, 8

	mov  edx, string
	call puts

	jmp .menu_while_start

.opt_exit:
	jmp .menu_while_exit

.opt_error:
	mov  edx, msg_menu_input_error
	call puts
	jmp  .menu_while_start

.menu_while_exit:
	mov eax, 1
	mov ebx, 0
	int 0x80

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

_atoi: ; atoi(char *, int)
push ebp
mov  ebp, esp
sub  esp, 8

mov dword [ebp-4], 0
mov dword [ebp-8], 1

mov esi, [ebp+8]
xor ecx, ecx
mov edx, [ebp+12]

.space_c_while_start:
	cmp ecx, [ebp+12]
	je  .atoi_leave

	cmp byte [esi + ecx], 32
	je  .has_space
	cmp byte [esi + ecx], 9
	je  .has_space
	jmp .break_space_while

.has_space:
	add ecx, 1
	jmp .space_c_while_start

.break_space_while:
	cmp byte [esi + ecx], '-'
	je  .has_minus_sign
	cmp byte [esi + ecx], '+'
	je  .has_sign
	jmp .str_for_cmp_start

.has_sign:
	add ecx, 1
	jmp .str_for_cmp_start

.has_minus_sign:
	mov dword [ebp-8], -1
	add ecx, 1

.str_for_cmp_start:
	lea esi, [esi + ecx]

	mov edx, [ebp + 12]
	sub edx, ecx

	xor ecx, ecx

	FOR ecx, edx, 1, strloop
	mov al, [esi + ecx]

	cmp al, '0'
	jl  .break_str_for_cmp
	cmp al, '9'
	ja  .break_str_for_cmp

	sub   al, '0'
	movzx eax, al
	mov   ebx, [ebp-4]
	imul  ebx, 10
	add   eax, ebx
	mov   [ebp-4], eax

.str_for_cmp_end:
	END_FOR ecx, edx, 1, strloop

.break_str_for_cmp:
	mov  eax, [ebp-4]
	mov  ebx, [ebp-8]
	imul eax, ebx
	mov  [ebp-4], eax

.atoi_leave:
	mov eax, [ebp - 4]
	leave
	ret

_itoa: ; itoa(int, char *)
push ebp
mov  ebp, esp
sub  esp, 16

mov dword [ebp - 4], 0
mov dword [ebp - 8], 0
mov dword [ebp - 12], 0
mov dword [ebp - 16], 0

	mov eax, [ebp + 8]
	cmp eax, 0
	jne .not_0
	mov esi, [ebp + 12]
	mov byte [esi], '0'
	mov byte [esi + 1], 10
	mov [ebp - 16], 1
	jmp .itoa_leave

.not_0:
	mov  eax, [ebp + 8]
	cmp  eax, 0
	jg   .not_negative
	imul eax, -1

.not_negative:
	mov [ebp - 4], eax
	mov ebx, 10
	mov eax, [ebp -4]
	xor edx, edx

.digits_while_start:
	cmp eax, 0
	je  .digits_while_end
	xor edx, edx
	div ebx
	add dword [ebp - 8], 1
	jmp .digits_while_start

.digits_while_end:
	mov eax, [ebp + 8]
	xor ecx, ecx
	xor edx, edx

	cmp  eax, 0
	setg cl
	setl dl

	sub ecx, edx
	mov [ebp-12], ecx
	mov eax, [ebp-8]
	add [ebp-16], eax

	cmp dword [ebp-12], -1
	jne .no_sign
	add dword [ebp-16], 1

.no_sign:
	mov esi, [ebp + 12]
	mov ebx, [ebp - 16]
	mov byte [esi + ebx], 10

	cmp dword [ebp-12], -1
	jne .no_neg

	mov  eax, [ebp -12]
	imul eax, -1
	mov  [ebp-12], eax
	mov  byte [esi], '-'

.no_neg:
	mov esi, [ebp+12]
	mov ebx, 10
	mov eax, [ebp - 4]
	xor edx, edx
	mov ecx, [ebp -16]

.fill_while_start:
	cmp eax, 0
	je  .fill_while_end
	sub ecx, 1
	xor edx, edx
	div ebx
	add dl, '0'
	mov [esi + ecx], dl
	jmp .fill_while_start

.fill_while_end:

.itoa_leave:
	add dword [ebp-16], 1
	mov eax, [ebp - 16]
	leave
	ret
