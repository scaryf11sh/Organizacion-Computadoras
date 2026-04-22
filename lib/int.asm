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
	push ebx
	push esi

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
	pop esi
	pop ebx
	leave
	ret

_itoa: ; itoa(int, char *)
push ebp
mov  ebp, esp
sub  esp, 16
push ebx
push esi

mov dword [ebp - 4], 0
mov dword [ebp - 8], 0
mov dword [ebp - 12], 0
mov dword [ebp - 16], 0

	mov eax, [ebp + 8]
	cmp eax, 0
	jne .not_0
	mov esi, [ebp + 12]
	mov byte [esi], '0'
	mov byte [esi + 1], 0
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
	mov byte [esi + ebx], 0

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
	mov eax, [ebp - 16]
	pop esi
	pop ebx
	leave
	ret
