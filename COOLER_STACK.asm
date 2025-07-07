%include "io.inc"

; =============================================
; constants and macros
; =============================================
%define STACK_SIZE      100
%define CMD_NUMBER      'N'
%define CMD_PRINT       '='
%define CMD_ADD         '+'
%define CMD_SUB         '-'
%define CMD_MUL         '*'
%define CMD_DIV         '/'
%define CMD_REM         '%'
%define CMD_SHOW        'S'
%define CMD_CLEAR       'C'
%define CMD_DUP         'D'
%define CMD_SWAP        'R'
%define CMD_SIZE        'L'
%define CMD_HEX         'H'
%define CMD_BIN         'B'
%define CMD_EXIT        'E'

%macro CHECK_CMD 2
    cmp al, %1
    je %2
%endmacro

; =============================================
; data segment
; =============================================
section .bss
    stack     resd STACK_SIZE
    top       resd 1
    cmd       resb 1
    temp_buf  resb 32

section .data
    err_overflow   db "Error: Stack overflow", 0
    err_underflow  db "Error: Stack underflow", 0
    err_empty      db "Error: Stack empty", 0
    err_div_zero   db "Error: Division by zero", 0
    err_unknown    db "Error: Unknown command '", 0
    msg_cleared    db "Stack cleared", 0
    msg_size       db "Stack size: ", 0
    msg_hex_prefix db "0x", 0
    msg_bin_prefix db "0b", 0

; =============================================
; main
; =============================================
section .text
global main
main:
    xor eax, eax
    mov [top], eax
    jmp start

; main loop
start:
    GET_CHAR [cmd]
    movzx eax, byte [cmd]

    ; command check
    CHECK_CMD CMD_NUMBER, input_number
    CHECK_CMD CMD_PRINT,  print_top
    CHECK_CMD CMD_ADD,    do_add
    CHECK_CMD CMD_SUB,    do_sub
    CHECK_CMD CMD_MUL,    do_mul
    CHECK_CMD CMD_DIV,    do_div
    CHECK_CMD CMD_REM,    do_rem
    CHECK_CMD CMD_SHOW,   show_stack
    CHECK_CMD CMD_CLEAR,  clear_stack
    CHECK_CMD CMD_DUP,    dup_top
    CHECK_CMD CMD_SWAP,   swap_top
    CHECK_CMD CMD_SIZE,   show_size
    CHECK_CMD CMD_HEX,    print_hex
    CHECK_CMD CMD_BIN,    print_bin
    CHECK_CMD CMD_EXIT,   exit_program

    ; ignore spaces
    cmp al, 0x20
    je start
    cmp al, 0xA
    je start
    cmp al, 0xD
    je start

    ; unknown command
    PRINT_STRING err_unknown
    PRINT_CHAR [cmd]
    PRINT_STRING "'"
    NEWLINE
    jmp start

; =============================================
; funcs in/out
; =============================================
input_number:
    GET_DEC 4, eax
    call push
    jmp start

print_top:
    call peek
    jc start
    PRINT_DEC 4, eax
    NEWLINE
    jmp start

print_hex:
    call peek
    jc start
    PRINT_STRING msg_hex_prefix
    PRINT_HEX 4, eax
    NEWLINE
    jmp start

print_bin:
    call peek
    jc start
    PRINT_STRING msg_bin_prefix
    mov ecx, 32       ; 32 bits for ou
.bin_loop:
    rol eax, 1
    push eax
    mov eax, 0
    adc al, '0'
    PRINT_CHAR al
    pop eax
    loop .bin_loop
    NEWLINE
    jmp start

; =============================================
; stack operations
; =============================================
clear_stack:
    xor eax, eax
    mov [top], eax
    PRINT_STRING msg_cleared
    NEWLINE
    jmp start

show_stack:
    mov ecx, [top]
    test ecx, ecx
    jz .empty
    mov esi, 0
.stack_loop:
    mov eax, [stack + esi*4]
    PRINT_DEC 4, eax
    NEWLINE
    inc esi
    cmp esi, ecx
    jl .stack_loop
    jmp start
.empty:
    PRINT_STRING err_empty
    NEWLINE
    jmp start

show_size:
    mov eax, [top]
    PRINT_STRING msg_size
    PRINT_DEC 4, eax
    NEWLINE
    jmp start

dup_top:
    call peek
    jc start
    call push
    jmp start

swap_top:
    call pop_two_operands
    jc start
    xchg eax, ebx
    call push
    xchg eax, ebx
    call push
    jmp start

; =============================================
; arithmetic operations
; =============================================
do_add:
    call pop_two_operands
    jc start
    add eax, ebx
    call push
    jmp start

do_sub:
    call pop_two_operands
    jc start
    sub eax, ebx
    call push
    jmp start

do_mul:
    call pop_two_operands
    jc start
    imul eax, ebx
    call push
    jmp start

do_div:
    call pop_two_operands
    jc start
    test ebx, ebx
    jz .div_zero
    cdq
    idiv ebx
    call push
    jmp start
.div_zero:
    PRINT_STRING err_div_zero
    NEWLINE
    call restore_operands
    jmp start

do_rem:
    call pop_two_operands
    jc start
    test ebx, ebx
    jz .rem_zero
    cdq
    idiv ebx
    mov eax, edx
    call push
    jmp start
.rem_zero:
    PRINT_STRING err_div_zero
    NEWLINE
    call restore_operands
    jmp start

; =============================================
; auxillary functions
; =============================================
pop_two_operands:
    call pop
    jc .error
    mov ebx, eax
    call pop
    jc .error
    clc
    ret
.error:
    stc
    ret

restore_operands:
    mov ecx, [top]
    cmp ecx, STACK_SIZE-1
    jge .skip
    mov eax, ebx
    call push
    mov eax, [esp]
    call push
.skip:
    ret

push:
    mov ecx, [top]
    cmp ecx, STACK_SIZE
    jge .overflow
    mov [stack + ecx*4], eax
    inc ecx
    mov [top], ecx
    ret
.overflow:
    PRINT_STRING err_overflow
    NEWLINE
    stc
    ret

pop:
    mov ecx, [top]
    test ecx, ecx
    jz .underflow
    dec ecx
    mov eax, [stack + ecx*4]
    mov [top], ecx
    clc
    ret
.underflow:
    PRINT_STRING err_underflow
    NEWLINE
    stc
    ret

peek:
    mov ecx, [top]
    test ecx, ecx
    jz .empty
    mov eax, [stack + (ecx-1)*4]
    clc
    ret
.empty:
    PRINT_STRING err_empty
    NEWLINE
    stc
    ret

exit_program:
    xor eax, eax
    ret