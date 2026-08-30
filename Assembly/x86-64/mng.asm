bits 64
default rel

section .text

global mng_is_mng
mng_is_mng:
    cmp rdx, 8
    jb .not_mng
    mov rax, [rcx]
    mov r10, 0x0A1A0A0D474E4D8A
    cmp rax, r10
    jne .not_mng
    mov eax, 1
    ret
.not_mng:
    xor eax, eax
    ret

global mng_frame_count
mng_frame_count:
    push r12
    cmp rdx, 8
    jb .invalid
    mov r8, rcx
    mov r9, rdx
    mov rax, [r8]
    mov rdx, 0x0A1A0A0D474E4D8A
    cmp rax, rdx
    jne .invalid
    mov r10, 8
    xor r11d, r11d
    xor r12d, r12d
.next_chunk:
    cmp r10, r9
    jae .complete
    mov rax, r9
    sub rax, r10
    cmp rax, 12
    jb .invalid
    movzx eax, byte [r8 + r10]
    shl rax, 24
    movzx edx, byte [r8 + r10 + 1]
    shl rdx, 16
    or rax, rdx
    movzx edx, byte [r8 + r10 + 2]
    shl rdx, 8
    or rax, rdx
    movzx edx, byte [r8 + r10 + 3]
    or rax, rdx
    mov rdx, rax
    add rdx, 12
    jc .invalid
    mov rax, r9
    sub rax, r10
    cmp rdx, rax
    ja .invalid
    cmp dword [r8 + r10 + 4], 0x52444849
    jne .not_ihdr
    test r12d, r12d
    jnz .advance
    mov r12d, 1
    jmp .advance
.not_ihdr:
    cmp dword [r8 + r10 + 4], 0x444E4549
    jne .advance
    test r12d, r12d
    jz .advance
    inc r11
    xor r12d, r12d
.advance:
    add r10, rdx
    jmp .next_chunk
.complete:
    test r12d, r12d
    jnz .invalid
    test r11, r11
    jz .invalid
    mov rax, r11
    pop r12
    ret
.invalid:
    xor eax, eax
    pop r12
    ret
