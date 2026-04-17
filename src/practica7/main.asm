%macro FOR 4; i, condicion, paso, label

.%4_start:
	cmp %1, %2
	jge .%4_end
	%endmacro

	%macro END_FOR 4
	add    %1, %3
	jmp    .%4_start

.%4_end:
	%endmacro

	section .data
	;       ----- Menú -----
	msg_menu_title      db "Seleccione una opcion:", 0xA
	len_menu_title      equ $ - msg_menu_title

	msg_menu_opt_atoi   db "1) atoi", 0xA
	len_menu_opt_atoi   equ $ - msg_menu_opt_atoi

	msg_menu_opt_itoa   db "2) itoa", 0xA
	len_menu_opt_itoa   equ $ - msg_menu_opt_itoa

	msg_menu_opt_exit   db "3) salir", 0xA
	len_menu_opt_exit   equ $ - msg_menu_opt_exit

	msg_menu_input      db "--> "
	len_menu_input      equ $ - msg_menu_input

	msg_menu_input_error db "Opcion no valida, intente de nuevo", 0xA
	len_menu_input_error equ $ - msg_menu_input_error

	; ----- Mensajes de entrada -----
	msg_input_str       db "Ingrese la cadena: ", 0
	len_input_str       equ $ - msg_input_str - 1

	msg_input_num       db "Ingrese el numero: ", 0
	len_input_num       equ $ - msg_input_num - 1

	; ----- Mensajes de salida -----
	msg_res_atoi        db "atoi -> "
	len_res_atoi      equ $ - msg_res_atoi
	msg_res_itoa        db "itoa -> ", 0
	len_res_itoa     equ $ - msg_res_itoa

	section .bss
	option  resd 1
	string  resb 32
	strlen  resd 1
	number  resd 1

	section .text
	global  _print
	;global _scan
	global  _atoi
	global  _itoa
	global  _start

_start:
	mov eax, 0

.menu_while_start:
	push len_menu_title
	push msg_menu_title
	call _print
	add  esp, 8

	push len_menu_opt_atoi
	push msg_menu_opt_atoi
	call _print
	add  esp, 8

	push len_menu_opt_itoa
	push msg_menu_opt_itoa
	call _print
	add  esp, 8

	push len_menu_opt_exit
	push msg_menu_opt_exit
	call _print
	add  esp, 8

	push len_menu_input
	push msg_menu_input
	call _print
	add  esp, 8

	;scan
	mov eax, 3
	mov ebx, 0
	mov ecx, string
	mov edx, 32
	int 0x80

	mov [strlen], eax

	push eax
	push string
	call _atoi; return en eax
	add  esp, 8

	cmp eax, 1
	jne .opt_itoa

	push len_input_str
	push msg_input_str
	call _print
	add  esp, 8

	mov eax, 3
	mov ebx, 0
	mov ecx, string
	mov edx, 32
	int 0x80

	mov [strlen], eax
	cmp eax, 0
	je  .a_error_handling
	mov byte [string + eax - 1], 32

.a_error_handling:
	push [strlen]
	push string
	call _print
	add  esp, 8

	push len_res_atoi
	push msg_res_atoi
	call _print
	add  esp, 8

	push [strlen]
	push string
	call _atoi
	add  esp, 8

	push string
	push eax
	call _itoa
	add  esp, 8

	mov  [strlen], eax
	push [strlen]
	push string
	call _print
	add  esp, 8

	jmp .menu_while_start

.opt_itoa:
	cmp eax, 2
	jne .opt_exit

	push len_input_num
	push msg_input_num
	call _print
	add  esp, 8

	mov eax, 3
	mov ebx, 0
	mov ecx, string
	mov edx, 32
	int 0x80

	mov [strlen], eax
	cmp eax, 0
	je  .b_error_handling
	mov [string + eax - 1], 32

.b_error_handling:
	push [strlen]
	push string
	call _print
	add  esp, 8

	push len_res_itoa
	push msg_res_itoa
	call _print
	add  esp, 8

	push [strlen]
	push string
	call _atoi
	add  esp, 8

	mov  [number], eax
	push string
	push [number]
	call _itoa
	add  esp, 8

	mov  [strlen], eax
	push [strlen]
	push string
	call _print
	add  esp, 8

	jmp .menu_while_start

.opt_exit:
	cmp eax, 3
	jne .opt_error
	jmp .menu_while_exit

.opt_error:
	push len_menu_input_error
	push msg_menu_input_error
	call _print
	add  esp, 8
	jmp  .menu_while_start

.menu_while_exit:
	mov eax, 1
	mov ebx, 0
	int 0x80

_print:
	push ebp
	mov  ebp, esp
	mov  eax, 4
	mov  ebx, 1
	mov  ecx, [ebp + 8]
	mov  edx, [ebp + 12]
	int  0x80
	leave
	ret

;_scan

_atoi: ; atoi(char *, int)
push ebp
mov  ebp, esp
sub  esp, 8; nums, result, sign

mov dword [ebp-4], 0; result = 0
mov dword [ebp-8], 1; sign = 1

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
	mov   [ebp -4], eax

.str_for_cmp_end:
	END_FOR ecx,edx,1,strloop

.break_str_for_cmp:
	mov  eax, [ebp-4]
	mov  ebx, [ebp-8]
	imul eax, ebx
	mov  [ebp-4], eax

.atoi_leave:
	mov eax, [ebp - 4]
	leave
	ret

_itoa:; itoa (int, char *) el 3 int es la base, pero usamos base 10 por defecto
push ebp
mov  ebp, esp
sub  esp, 16; copy, digits, sign, strlen

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
	mov ebx, 10; divisor en 10
	mov eax, [ebp -4]; eax = num
	xor edx, edx; edx.eax 0.num

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
	mov ecx, [ebp -16 ]

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
