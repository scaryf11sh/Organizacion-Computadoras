	extern getch
	extern putchar

	global capturar

	section .text

; capturar: convencion propia (args en registros, no en stack) para evitar overhead
;           de frame en una funcion de uso frecuente e interactivo
;           ax = maximo de caracteres incluyendo el nulo final
;           edx = direccion del buffer destino
capturar:
	push  ebx   ; callee-saved; lo usamos para guardar el inicio del buffer
	push  ecx   ; tecnicamente caller-saved en cdecl, pero lo guardamos porque
	            ; lo repropusimos como contador descendente (loop lo decrementa)

	movzx ecx, ax  ; ecx = slots disponibles incluyendo nulo; extender a 32 bits para usar loop
	dec   ecx      ; reservar 1 slot para el nulo final, asi loop no lo pisa
	mov   ebx, edx ; ebx = inicio del buffer; referencia fija para detectar posicion 0 (no retroceder mas)

.ciclo:
	call getch
	cmp  al, 127       ; 127 = DEL, que es lo que envia la terminal en modo raw al presionar backspace
	jne  .guardar      ; no es backspace: guardar normal

	cmp  edx, ebx      ; si edx == ebx estamos al inicio del buffer: no hay nada que borrar
	je   .ciclo
	dec  edx           ; retroceder el puntero para sobreescribir el ultimo caracter
	inc  ecx           ; devolver el slot al contador para que loop no corte antes de tiempo
	call borrar        ; borrar visualmente en la terminal antes de continuar
	jmp  .ciclo

.guardar:
	call putchar       ; eco inmediato: getch no hace eco en modo raw
	mov  [edx], al
	cmp  al, 0xa       ; enter termina la captura; el nulo se escribe en esa posicion
	je   .salir
	inc  edx
	loop .ciclo        ; loop decrementa ecx y salta; si ecx llega a 0 el buffer esta lleno

.salir:
	mov byte [edx], 0  ; nulo terminal: garantizado sin importar si salio por enter o por buffer lleno
	pop ecx
	pop ebx
	ret

; borrar no es global porque es un detalle de implementacion de capturar;
; ningun otro modulo deberia depender de esta secuencia especifica de escape
borrar:
	push eax
	mov  al, 0x8   ; backspace mueve el cursor a la izquierda sin borrar
	call putchar
	mov  al, ' '   ; espacio sobreescribe el caracter visible
	call putchar
	mov  al, 0x8   ; segundo backspace deja el cursor sobre la posicion borrada
	call putchar
	pop  eax
	ret
