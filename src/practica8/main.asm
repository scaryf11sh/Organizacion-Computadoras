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
	times 5 dd 4       ; inicializado en 4 (no 0) para que haya valores visibles antes de llenar

	arr_lenght: dd 5   ; dd en vez de db para que push [arr_lenght] lea un dword limpio sin basura en bytes altos

string:
	times 32 db 0      ; en .data (no .bss) para quedar junto a strlen y arr_lenght; capturar necesita que este inicializado

strlen:
	dd 32              ; tamano maximo separado del buffer para poderlo pasar como argumento dword a _atoi y como ax a capturar

	section .bss
	option  resd 1
	value   resd 1

	section .text
	global  _start
	global  _print_array
	global  _sort_array
	global  _scan_array  ; global para poder llamarlas desde otros modulos o tests

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

	call getche        ; getche hace eco automatico; no necesitamos putchar manual como en practica7
	mov  [option], eax

	mov  al, 0xA
	call putchar       ; newline tras el caracter elegido; getche no lo agrega

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
	push [arr_lenght]  ; pasar el valor (no la direccion) para que la funcion use cmp directo
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
	call _sort_array   ; _sort_array llama a _print_array internamente al terminar
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

	; [ebp-4] = i, contador del loop; vive en memoria porque puts destruye registros
	;           via int 0x80 (sets ebx=1 para fd=stdout) en cada llamada
	mov [ebp -4 ], 0

	mov  al, '['
	call putchar

.pa_while_start:
	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .pa_while_end

	mov esi, [ebp + 8]         ; recargar base del arreglo cada iteracion: puts puede destruir esi
	                           ; (algunas implementaciones lo usan para recorrer la cadena con lodsb)

	push string
	lea  esi, [esi + ecx*4]    ; *4 porque cada elemento es dd (4 bytes); lea calcula la direccion sin leer memoria
	push [esi]
	call _itoa
	add  esp, 8

	add dword [ebp - 4], 1     ; incrementar antes de puts para no depender de eax despues de la llamada

	mov  edx, string
	call puts

	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .pa_while_start        ; ultimo elemento: saltar al inicio donde el cmp lo manda a pa_while_end (sin coma)

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

	; [ebp-4] = i, indice actual; en memoria porque capturar y _atoi destruyen registros
	mov [ebp - 4], 0

.fa_while_start:
	mov ecx, [ebp - 4]
	cmp ecx, [ebp + 12]
	jge .fa_while_end

	mov  edx, msg_menu_input_arr_index
	call puts

	mov  al, [ebp - 4]
	add  al, '0'               ; convertir indice a ASCII para mostrarlo; funciona hasta indice 9
	call putchar

	mov  al, 32
	call putchar

	mov  edx, msg_menu_input
	call puts

	mov  edx, string           ; capturar escribe en string; luego _atoi lee del mismo buffer
	mov  eax, [strlen]         ; capturar toma ax (16 bits); strlen cabe en al sin truncar
	call capturar

	push [strlen]
	push string
	call _atoi                 ; convertir lo capturado a entero antes de almacenar
	add  esp, 8

	; recargar esi e indice despues de _atoi: puede haber destruido registros
	mov esi, [ebp + 8]
	mov ecx, [ebp - 4]
	mov dword [esi + ecx * 4], eax   ; guardar el entero en la posicion correcta del arreglo

	add [ebp - 4], 1

	jmp .fa_while_start

.fa_while_end:
	pop ebx
	pop esi
	leave
	ret

	; _sort_array (int *arr, int size)
	; selection sort: en cada paso exterior se busca el minimo del subarreglo restante y se intercambia

_sort_array:
	push ebp
	mov  ebp, esp
	sub  esp, 16

	; [ebp-4]  = i, indice del loop externo (posicion donde va el minimo encontrado)
	; [ebp-8]  = j, indice del loop interno (recorre el subarreglo arr[i+1..n-1])
	; [ebp-12] = reservado para temp; en la practica el swap usa ecx/edx directamente
	; [ebp-16] = min_index, indice del elemento mas pequeno encontrado en el loop interno
	mov [ebp - 4], 0; i
	mov [ebp - 8], 0; j
	mov [ebp - 12], 0; temp
	mov [ebp - 16], 0; min_index

	push esi
	push ebx

	mov edx, [ebp + 12]
	sub edx, 1; n - 1          ; el loop externo va hasta n-2: el ultimo elemento ya queda en su lugar

	FOR [ebp - 4], edx, 1, ext_for

	mov eax, [ebp -4]
	mov [ebp - 16], eax        ; min_index empieza en i; el loop interno lo actualiza si encuentra algo menor

	mov ecx, [ebp + 12]        ; ecx = n, limite del loop interno
	mov ebx, [ebp - 4]
	add ebx, 1
	mov [ebp - 8], ebx         ; j empieza en i+1 para no comparar un elemento consigo mismo

	FOR    [ebp - 8], ecx, 1, inn_for
	;      eax y ebx free, edx -> n -1, ecx, n
	;mover arr[j] a eax y arr[min_index] a ebx
	;      j = [ebp - 8]
	mov    esi, [ebp + 8]
	mov    eax, [ebp - 8]
	mov    eax, [esi + eax*4]  ; arr[j]
	mov    ebx, [ebp - 16]
	mov    ebx, [esi + ebx*4]  ; arr[min_index]

	cmp eax, ebx; arr[j] < arr[min_index]
	jge .next_inn              ; no es menor: min_index no cambia

	mov eax, [ebp-8]
	mov [ebp - 16], eax        ; encontramos un nuevo minimo: actualizar min_index

.next_inn:
	END_FOR [ebp - 8], ecx, 1, inn_for

	mov eax, [ebp - 16]
	cmp [ebp - 4], eax
	je  .next_ext              ; min_index == i: el minimo ya esta en su lugar, no hace falta intercambiar

	mov esi, [ebp + 8]

	mov ebx, [ebp - 16]
	mov eax, [ebp - 4]

	push edx               ; edx y ecx guardan los limites de los loops; el swap los necesita como temporales
	push ecx

	mov ecx, [esi + ebx*4]     ; arr[min_index]
	mov edx, [esi + eax*4]     ; arr[i]
	mov [esi + eax*4], ecx     ; arr[i] = arr[min_index]
	mov [esi + ebx*4], edx     ; arr[min_index] = arr[i]

	pop ecx
	pop edx

.next_ext:
	END_FOR [ebp - 4], edx, 1 , ext_for

	; mostrar el arreglo ordenado sin obligar al caller a hacer la llamada por separado
	push [ebp + 12]
	push [ebp + 8]
	call _print_array
	add  esp, 8

	pop ebx
	pop esi
	leave
	ret
