extern _itoa
extern _atoi
extern capturar

%include "../../lib/pc_io.inc"

section .data
msg_menu_title: db "Seleccione una opcion:", 0xA, 0
msg_menu_opt_get_arr: db "1) Llenar Arreglo", 0xA, 0
msg_menu_opt_print_arr: db "2) Imprimir Arreglo", 0xA, 0
msg_menu_opt_sort_arr: db "3) Ordenar Arreglo", 0xA, 0
msg_menu_opt_exit: db "4) Salir", 0xA, 0
msg_menu_input: db "--> ", 0
msg_menu_input_error: db "Opcion no valida, intente de nuevo", 0xA, 0
msg_menu_input_arr_index: db "Ingresa un numero para la posicion ", 0

arr:
	times 5 dd 0
	arr_lenght: db 5

	section .bss
	option  resd 1
	value   resd 1
	string  resb 32

	section .text
	global  _start
	global  _print_array
	global  _sort_array
	global  _scan_array

_start:

.menu_while_start:
	mov  edx, msg_menu_title
	call puts

	mov  edx, msg_menu_opt_get_arr
	call puts

	mov  edx, msg_menu_opt_print_arr
	call puts

	mov  edx, msg_menu_opt_sort_arr
	call puts

	mov  edx, msg_menu_opt_exit
	call puts

	mov  edx, msg_menu_input
	call puts

	call getche
	mov  [option], eax

	mov  al, 0xA
	call putchar

	mov eax, [option]
	cmp al, '1'
	je  .opt_get_array
	cmp al, '2'
	je  .opt_print_array
	cmp al, '3'
	je  .opt_sort_array
	cmp al, '4'
	je  .opt_exit
	jmp .opt_error

.opt_get_array:
	push [arr_lenght]
	push arr
	call _fill_array
	add  esp, 8
	jmp  .menu_while_start

.opt_print_array:
	push [arr_lenght]
	push arr
	call _print_array
	add  esp, 8
	jmp  .menu_while_start

.opt_sort_array:
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

	; _print_array (int *array, int size)

_print_array:
	push ebp
	mov  ebp, esp
	sub  esp, 4; [ebp-4] = contador
	push esi
	push ebx

	mov  al, '['
	call putchar

	mov dword [ebp-4], 0

.pa_while_start:
	mov  eax, [ebp-4]
	cmp  eax, [ebp + 12]
	jge  .pa_while_end

	mov  esi, [ebp + 8]        ; recargar: puts puede destruir esi
	mov  ebx, eax
	push string
	push dword [esi + ebx*4]
	call _itoa
	add  esp, 8

	mov  byte [string + eax - 1], 0

	mov  edx, string
	call puts

	mov  eax, [ebp-4]
	inc  eax
	mov  [ebp-4], eax

	cmp  eax, [ebp + 12]
	jge  .pa_while_end

	mov  al, ','
	call putchar

	mov  al, 32
	call putchar

	jmp  .pa_while_start

.pa_while_end:

	mov  al, ']'
	call putchar

	pop ebx
	pop esi
	leave
	ret

	; _fill_array (int *array, int size)

_fill_array:
	push ebp
	mov  ebp, esp
	push esi
	push ebx

	xor ebx, ebx
	mov esi, [ebp + 8]

.fa_while_start:
	cmp ecx, [ebp + 12]
	jge .fa_while_end

	mov  edx, msg_menu_input_arr_index
	call puts

	mov  edx, ecx
	add  edx, '0'
	call putchar

	mov  edx, msg_menu_input
	call puts

	mov  eax, 32
	mov  edx, string
	call capturar

.fa_while_end:

	leave
	ret

