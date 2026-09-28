.data 
    input1:         .string "Enter first string: "
    input1_len =    . - input1 - 1

    input2:         .string "Enter second string: "
    input2_len =    . - input2 - 1

    result_msg:     .string "Hamming distance: "
    result_len =    . - result_msg - 1


.bss                
    # reserving space for variable
    .lcomm str1, 256           # reserve 256 bytes for string 1
    .lcomm str2, 256           # reserve 256 bytes for string 2
    .lcomm out_buf, 16         # buffer to store integer ASCII string

.text
.globl main

main:
   # input and read for string 1
   movq $1, %rax               # sys_write 
   movq $1, %rdi               # stdout
   movq $input1, %rsi
   movq $input1_len, %rdx
   syscall

   movq $0, %rax               # sys_read
   movq $0, %rdi               # stdin
   movq $str1, %rsi
   movq $256, %rdx 
   syscall

   # input and read for string 2
   movq $1, %rax               #sys_write 
   movq $1, %rdi               # stdout
   movq $input2, %rsi
   movq $input2_len, %rdx
   syscall

   movq $0, %rax               #sys_read
   movq $0, %rdi               # stdin
   movq $str2, %rsi
   movq $256, %rdx 
   syscall

   # computing hamming distance
   movq $str1, %rsi
   movq $str2, %rdi
   xorq %r12, %r12             # r12 is for incrementing hamming distance

compare_loop:
    movzbq (%rsi), %r8         # loads 1 byte from str1
    movzbq (%rdi), %r9         # loads 1 byte from str2

    # check for string conditions
    testq %r8, %r8
    jz done_compare
    cmpq $10, %r8                 
    je done_compare

    testq %r9, %r9
    jz done_compare
    cmpq $10, %r9
    je done_compare

    # XOR & count
    xorq %r9, %r8             # r8 represents the differing bits
    popcntq %r8, %r8
    addq  %r8, %r12           # add to total distance

    incq %rsi                 # go to next char in str1
    incq %rdi                 # go to next char in str2
    jmp compare_loop          # repeats compare_loop

done_compare:
    # prints the result
    movq $1, %rax             # sys_write
    movq $1, %rdi             # stdout
    movq $result_msg, %rsi
    movq $result_len, %rdx
    syscall

    # changes integer in r12 to ASCII to print 
    movq %r12, %rax 
    movq $out_buf, %rdi        
    addq $15, %rdi
    movb $10, (%rdi)          #adds a new line
    movq $10, %rbx

convert_loop:
    decq %rdi
    xorq %rdx, %rdx
    divq %rbx                 # divide rax by 10
    addb $'0', %dl            # convert remainder to ASCII digit
    movb %dl, (%rdi)
    testq %rax, %rax
    jnz convert_loop

    # prints the distance 
    movq $out_buf, %rdx
    addq $16, %rdx
    subq %rdi, %rdx           # calculates length of output string
    movq %rdi, %rsi
    movq $1, %rax             # sys_write
    movq $1, %rdi             # stdout
    syscall

    # exits program
    movq $60, %rax            # sys_exit
    xorq %rdi, %rdi               
    syscall

.section .note.GNU-stack,"",@progbits
