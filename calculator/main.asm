.org 0x0000

start:
    ; Init the stack
    ldi rsp, 0x8000

    ; Initialize the terminal
    call term_init
    call term_clear_screen
    call term_flush

    ; Print title
    ldi r0, title_str
    call term_println

    ; r3 contains the amount of numbers in the stack
    ; therefore also the line at which we currently are
    xor r3, r3

input_loop:
    ldi r0, 0
    mov r1, r3
    inc r1
    call term_set_cursor

    ldi r0, prompt_str
    call term_print
    call term_flush

    ldi r0, 2
    mov r1, r3
    inc r1
    call term_set_cursor

    ldi r0, input_buffer
    ldi r1, size_buffer
    call kbd_read_line

    ; get first char
    ld r4, [r0]
    ld r5, [add_str]
    cmp r4, r5
    jmp@eq add_nums

    ld r5, [sub_str]
    cmp r4, r5
    jmp@eq sub_nums

    ld r5, [mul_str]
    cmp r4, r5
    jmp@eq mul_nums

    ld r5, [div_str]
    cmp r4, r5
    jmp@eq div_nums

    ld r5, [modulo_str]
    cmp r4, r5
    jmp@eq modulo_nums

    ld r5, [drop_str]
    cmp r4, r5
    jmp@eq drop_num

    ; we have a number to parse

    ; do parsing
    xor r2, r2
atoi_loop:
    ld r4, [r0]
    ; check for NULL
    xor r5, r5 
    cmp r4, r5
    jmp@eq atoi_finished
    ; check if it is in '0' and '9'
    ldi r5, 0x30
    sub r4, r5
    jmp@lo atoi_finished
    ldi r5, 9
    cmp r4, r5
    jmp@gr atoi_finished
    ; add char to value
    ldi r5, 10
    mul r2, r5
    add r2, r4
    
    inc r0
    jmp atoi_loop

atoi_finished:

    ; add number to stack
    push r2
    inc r3

    jmp input_loop

add_nums:
    ldi r0, 2
    cmp r3, r0
    jmp@lo reset_prompt

    pop r1
    pop r0
    add r0, r1
    dec r3
    push r0
    mov r4, r0

    jmp print_result

sub_nums:
    ldi r0, 2
    cmp r3, r0
    jmp@lo reset_prompt

    pop r1
    pop r0
    sub r0, r1
    dec r3
    push r0
    mov r4, r0

    jmp print_result

mul_nums:
    ldi r0, 2
    cmp r3, r0
    jmp@lo reset_prompt

    pop r1
    pop r0
    mul r0, r1
    dec r3
    push r0
    mov r4, r0

    jmp print_result

div_nums:
    ldi r0, 2
    cmp r3, r0
    jmp@lo reset_prompt

    pop r1

    ; 0 divider check
    ldi r2, 0
    cmp r1, r2
    jmp@ne _div_nums_contd
    push r1
    jmp reset_prompt

_div_nums_contd:
    pop r0

    call div16
    
    dec r3
    push r1 
    mov r4, r1

    jmp print_result

modulo_nums:
    ldi r0, 2
    cmp r3, r0
    jmp@lo reset_prompt

    pop r1

    ; 0 divider check
    ldi r2, 0
    cmp r1, r2
    jmp@ne _modulo_nums_contd
    push r1
    jmp reset_prompt

_modulo_nums_contd:
    pop r0

    call div16

    dec r3
    push r0
    mov r4, r0

    jmp print_result

print_result:
    ; rm op
    mov r0, r3
    inc r0
    inc r0
    call term_clear_line

    ldi r0, 0
    mov r1, r3
    ; do not increase here
    call term_set_cursor

    ldi r0, prompt_str
    call term_print

    ldi r0, 2
    mov r1, r3
    call term_set_cursor

    ; print number
    ldi r0, number_buffer
    mov r1, r4

    call itoa10
    call term_print

    call term_new_line
    jmp input_loop

drop_num:
    ldi r0, 1
    cmp r3, r0
    jmp@lo reset_prompt

    pop r0

    mov r0, r3
    call term_clear_line
    inc r0
    call term_clear_line
    
    dec r3

    jmp input_loop

reset_prompt:
    mov r0, r3
    inc r0
    call term_clear_line

    jmp input_loop

end:
    hlt

input_buffer: .skip 11
size_buffer: .word 10

number_buffer: .skip 10