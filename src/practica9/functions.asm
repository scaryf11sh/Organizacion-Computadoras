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

	section .text
	global  minimo
	global  maximo
	global  sumatoria

minimo:
	push ebp
	mov  ebp, esp

	push esi
	push ecx

	mov esi, [ebp + 8]
	xor ecx, ecx
	inc ecx
	mov eax, [esi]

	cmp [ebp + 12], 2
	jl  .exit

	FOR ecx, [ebp + 12], 1, min_for
	cmp eax, [esi + ecx * 4]
	jl  .continue

	mov eax, [esi + ecx * 4]

.continue:
	END_FOR ecx, [ebp + 12], 1, min_for

.exit:
	pop ecx
	pop esi
	leave
	ret

maximo:
	push ebp
	mov  ebp, esp

	push esi
	push ecx

	mov esi, [ebp + 8]
	xor ecx, ecx
	inc ecx
	mov eax, [esi]

	cmp [ebp + 12], 2
	jl  .exit

	FOR ecx, [ebp + 12], 1, max_for
	cmp eax, [esi + ecx * 4]; max > arr[i]??
	jge .continue

	mov eax, [esi + ecx * 4]

.continue:
	END_FOR ecx, [ebp + 12], 1, max_for

.exit:
	pop ecx
	pop esi
	leave
	ret

sumatoria:
	push ebp
	mov  ebp, esp

	push esi
	push ecx

	mov esi, [ebp + 8]
	xor ecx, ecx
	inc ecx
	mov eax, [esi]

	cmp [ebp + 12], 2
	jl  .exit

	FOR ecx, [ebp + 12], 1, sum_for
	add eax, [esi + ecx * 4]

	END_FOR ecx, [ebp + 12], 1, sum_for

.exit:
	pop ecx
	pop esi
	leave
	ret
