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

	global _atoi
	global _itoa

	section .text

	_atoi: ; atoi(char *, int)
	push ebp
	mov  ebp, esp
	sub  esp, 8
	push ebx       ; callee-saved: cdecl exige preservarlo
	push esi       ; callee-saved: lo usamos como puntero base de la cadena

	; [ebp-4] = resultado acumulado; empieza en 0 para poder sumar digitos
	; [ebp-8] = multiplicador de signo (1 o -1); default positivo, se cambia si hay '-'
	mov dword [ebp-4], 0
	mov dword [ebp-8], 1

	mov esi, [ebp+8]   ; base de la cadena; ecx sera el offset relativo
	xor ecx, ecx
	mov edx, [ebp+12]  ; limite de caracteres a revisar

.space_c_while_start:
	cmp ecx, [ebp+12]
	je  .atoi_leave    ; cadena vacia o solo espacios: devolver 0

	cmp byte [esi + ecx], 32
	je  .has_space
	cmp byte [esi + ecx], 9  ; tab tambien es espacio valido segun comportamiento de C atoi
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
	mov dword [ebp-8], -1  ; guardamos -1 para aplicarlo al final con una sola imul
	add ecx, 1

.str_for_cmp_start:
	lea esi, [esi + ecx]   ; avanzar el puntero base para que ecx pueda reiniciarse en 0

	mov edx, [ebp + 12]
	sub edx, ecx           ; recalcular limite: solo los chars restantes tras el prefijo

	xor ecx, ecx

	FOR ecx, edx, 1, strloop
	mov al, [esi + ecx]

	cmp al, '0'
	jl  .break_str_for_cmp  ; primer caracter no-digito: parar, igual que C atoi
	cmp al, '9'
	ja  .break_str_for_cmp

	sub   al, '0'          ; los digitos ASCII empiezan en 0x30; restar da el valor 0-9
	movzx eax, al
	mov   ebx, [ebp-4]
	imul  ebx, 10          ; desplazar el acumulado una posicion decimal a la izquierda
	add   eax, ebx
	mov   [ebp-4], eax

.str_for_cmp_end:
	END_FOR ecx, edx, 1, strloop

.break_str_for_cmp:
	mov  eax, [ebp-4]
	mov  ebx, [ebp-8]
	imul eax, ebx          ; aplicar signo una sola vez al final en vez de ramificar por digito
	mov  [ebp-4], eax

.atoi_leave:
	mov eax, [ebp - 4]
	pop esi    ; restaurar antes de leave: leave resetea esp a ebp perdiendo acceso al stack
	pop ebx
	leave
	ret

_itoa: ; itoa(int, char *)
push ebp
mov  ebp, esp
sub  esp, 16
push ebx   ; callee-saved
push esi   ; callee-saved; sub esp primero para que los locals queden en [ebp-4]..[ebp-16]

; [ebp-4]  = valor absoluto del entero; separado del original para no perder el signo
; [ebp-8]  = cantidad de digitos; se cuenta dividiendo repetidamente entre 10
; [ebp-12] = signo: 1 si positivo, -1 si negativo, 0 si cero (no usado en practica)
; [ebp-16] = longitud total del string antes del null (digitos + posible '-')
mov dword [ebp - 4], 0
mov dword [ebp - 8], 0
mov dword [ebp - 12], 0
mov dword [ebp - 16], 0

	mov eax, [ebp + 8]
	cmp eax, 0
	jne .not_0
	mov esi, [ebp + 12]
	mov byte [esi], '0'
	mov byte [esi + 1], 0    ; caso especial: div por 0 causaria fault; ademas evita logica de signo innecesaria
	mov [ebp - 16], 1
	jmp .itoa_leave

.not_0:
	mov  eax, [ebp + 8]
	cmp  eax, 0
	jg   .not_negative
	imul eax, -1             ; div necesita dividendo positivo; el signo ya esta en [ebp-12]

.not_negative:
	mov [ebp - 4], eax
	mov ebx, 10
	mov eax, [ebp -4]
	xor edx, edx

.digits_while_start:
	cmp eax, 0
	je  .digits_while_end
	xor edx, edx
	div ebx                  ; solo nos interesa el cociente para contar; el resto se descarta
	add dword [ebp - 8], 1
	jmp .digits_while_start

.digits_while_end:
	mov eax, [ebp + 8]
	xor ecx, ecx
	xor edx, edx

	cmp  eax, 0
	setg cl    ; cl=1 si positivo
	setl dl    ; dl=1 si negativo

	sub ecx, edx        ; ecx = 1 (pos), 0 (cero), -1 (neg) sin ramificar
	mov [ebp-12], ecx
	mov eax, [ebp-8]
	add [ebp-16], eax   ; longitud inicial = cantidad de digitos

	cmp dword [ebp-12], -1
	jne .no_sign
	add dword [ebp-16], 1   ; reservar un byte extra para el '-'

.no_sign:
	mov esi, [ebp + 12]
	mov ebx, [ebp - 16]
	mov byte [esi + ebx], 0  ; escribir el null antes del loop: el loop llena de derecha a izquierda y necesita saber donde termina

	cmp dword [ebp-12], -1
	jne .no_neg

	mov  eax, [ebp -12]
	imul eax, -1
	mov  [ebp-12], eax
	mov  byte [esi], '-'     ; el '-' va en posicion 0; los digitos llenan desde [ebp-16]-1 hacia atras

.no_neg:
	mov esi, [ebp+12]
	mov ebx, 10
	mov eax, [ebp - 4]    ; valor absoluto
	xor edx, edx
	mov ecx, [ebp -16]    ; ecx = posicion de escritura; va decrementando hacia la izquierda

.fill_while_start:
	cmp eax, 0
	je  .fill_while_end
	sub ecx, 1
	xor edx, edx
	div ebx               ; div da digito menos significativo en edx; el loop los escribe de atras para adelante
	add dl, '0'
	mov [esi + ecx], dl
	jmp .fill_while_start

.fill_while_end:

.itoa_leave:
	mov eax, [ebp - 16]   ; devolver longitud para que el caller pueda indexar el buffer sin strlen
	pop esi
	pop ebx
	leave
	ret
