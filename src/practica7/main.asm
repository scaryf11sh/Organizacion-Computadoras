%macro print 2
mov    eax, 4
mov    ebx, 1
mov    ecx, %1
mov    edx, %2
int    0x80
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

	; ----- Mensajes de entrada -----
	msg_input_str       db "Ingrese la cadena:", 0
	len_input_str       equ $ - msg_input_str

	msg_input_num       db "Ingrese el numero:", 0
	len_input_num       equ $ - msg_input_num

	; ----- Mensajes de salida -----
	msg_res_atoi        db "atoi -> '", 0
	msg_res_itoa        db "itoa -> ", 0

	section .text
	global  _start

_start:
	print msg_menu_title, len_menu_title
	mov   eax, 1
	mov   ebx, 0
	int   0x80
