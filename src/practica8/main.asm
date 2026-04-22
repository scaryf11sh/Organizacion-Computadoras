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
	times 5 dd 4

	arr_lenght: dd 5

string:
	times 32 db 0

strlen:
	dd 32

	section .bss
	option  resd 1
	value   resd 1

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
	push [arr_lenght]
	push arr
	call _sort_array
	add  esp, 8
	jmp  .menu_while_start

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

	mov [ebp -4 ], 0

	mov  al, '['
	call putchar

.pa_while_start:
	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .pa_while_end

	mov esi, [ebp + 8]

	push string
	lea  esi, [esi + ecx*4]
	push [esi]
	call _itoa
	add  esp, 8

	add dword [ebp - 4], 1

	mov  edx, string
	call puts

	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .pa_while_start

	mov  al, ','
	call putchar

	jmp .pa_while_start

.pa_while_end:
	mov  al, ']'
	call putchar

	mov  al, 10
	call putchar

	pop ebx
	pop esi
	leave
	ret

	; _fill_array (int *array, int size)

_fill_array:
	push ebp
	mov  ebp, esp
	sub  esp, 4; [ebp - 4] = contador

	push esi
	push ebx

	mov [ebp - 4], 0

.fa_while_start:
	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .fa_while_end

	mov  edx, msg_menu_input_arr_index
	call puts

	mov  al, [ebp - 4]
	add  al, '0'
	call putchar

	mov  al, 32
	call putchar

	mov  edx, msg_menu_input
	call puts

	mov  edx, string
	mov  eax, [strlen]
	call capturar

	push [strlen]
	push string
	call _atoi
	add  esp, 8

	mov esi, [ebp + 8]
	mov ecx, [ebp - 4]
	mov dword [esi + ecx * 4], eax

	add [ebp - 4], 1

	jmp .fa_while_start

.fa_while_end:
	pop ebx
	pop esi
	leave
	ret

	; (int *arr, int size)

_sort_array:
	push ebp
	mov  ebp, esp
	sub  esp, 16

	mov [ebp - 4], 0; i
	mov [ebp - 8], 0; j
	mov [ebp - 12], 0; temp
	mov [ebp - 16], 0; min_index

	push esi
	push ebx

	mov edx, [ebp + 12]
	sub edx, 1; n - 1

	FOR [ebp - 4], edx, 1, ext_for

	mov eax, [ebp -4]
	mov [ebp - 16], eax

	mov ecx, [ebp + 12]
	mov ebx, [ebp - 4]
	add ebx, 1
	mov [ebp - 8], ebx

	FOR    [ebp - 8], ecx, 1, inn_for
	;      eax y ebx free, edx -> n -1, ecx, n
	;mover arr[j] a eax y arr[min_index] a ebx
	;      j = [ebp - 8]
	mov    esi, [ebp + 8]
	mov    eax, [ebp - 8]
	mov    eax, [esi + eax*4]
	mov    ebx, [ebp - 16]
	mov    ebx, [esi + ebx*4]

	cmp eax, ebx; arr[j] < arr[min_index]
	jge .next_inn

	mov eax, [ebp-8]
	mov [ebp - 16], eax

.next_inn:
	END_FOR [ebp - 8], ecx, 1, inn_for

	mov eax, [ebp - 16]
	cmp [ebp - 4], eax
	je  .next_ext

	mov esi, [ebp + 8]

	mov ebx, [ebp - 16]
	mov eax, [ebp - 4]

	push edx
	push ecx

	mov ecx, [esi + ebx*4]
	mov edx, [esi + eax*4]
	mov [esi + eax*4], ecx
	mov [esi + ebx*4], edx

	pop ecx
	pop edx

.next_ext:
	END_FOR [ebp - 4], edx, 1 , ext_for

	push [ebp + 12]
	push [ebp + 8]
	call _print_array
	add  esp, 8

	pop ebx
	pop esi
	leave
	ret
