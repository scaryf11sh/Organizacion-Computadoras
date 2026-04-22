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
	extern   _itoa
	extern   _atoi
	extern   capturar

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

	call getch         ; getch no hace eco; lo hacemos manual para controlar el formato
	mov  [option], eax
	call putchar       ; eco del caracter elegido
	mov  al, 0xa
	call putchar       ; newline manual porque getch no lo agrega

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

	push dword 32      ; limite de lectura igual al tamano del buffer para evitar leer basura fuera
	push string
	call _atoi
	add  esp, 8

	; reutilizamos el mismo buffer: atoi ya termino de leer, itoa puede sobreescribirlo
	push string
	push eax
	call _itoa
	add  esp, 8

	mov  edx, string
	call puts
	add  esp, 8

	mov  al, 10
	call putchar       ; newline de separacion antes de volver al menu

	jmp .menu_while_start

.opt_itoa:
	mov  edx, msg_input_num
	call puts

	mov  ax, 32
	mov  edx, string
	call capturar

	mov  edx, msg_res_itoa
	call puts

	; opt_itoa tambien pasa por atoi primero para normalizar la entrada del usuario
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

	mov  al, 10
	call putchar

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
