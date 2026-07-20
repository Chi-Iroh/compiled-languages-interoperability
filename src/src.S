BITS 64
default rel

global asm_hello

section .rodata
    greeting db "Hello, world from Assembly !", 10, 0
    greeting_sz equ $-greeting


section .text
asm_hello:
    push rbp
    push rsp

    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    lea rsi, greeting
    mov rdx, greeting_sz
    syscall

    pop rsp
    pop rbp

    ret
