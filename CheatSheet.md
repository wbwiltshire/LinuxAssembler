Linux Assemble code (X86_64 - GAS) - Cheat Sheet
===

### Registers
| Register      | Accumulator | Counter | Data  | Base  | Stack | Stack Base | Source | Destination
| ------------- |-------------| ------- | ----- | ----- | ------------- | ---------- | ------ | -----------
| 8 bit         | ah al       | ch cl   | dh dl | bh bl | | | | |
| 16 bit        | ax          | cx      | dx    | bx    | sp    | bp         | si     | di
| 32 bit        | eax         | ecx     | edx   | ebx   | esp   | ebp        | esi    | edi
| 64 bit        | rax         | rcx     | rdx   | rbx   | rsp   | rbp        | rsi    | rdi
| 64 bit only   | r8 - r16    |||||||||

### Storage section
```
.data

.byte 			# 8 bit
.int 			# 16 bit
.word 			# 16 bit
.long 			# 32 bit
.quad 			# 64 bit
.ascii
.asciz
```

### Memory layout
| High mem | Description |
| -------- | - |
| Stack    | builds downward |
| Unused   | unallocated     |
| Heap     | malloc          |
| .bss     | buffer space    |
| .data    | fixed data      |
| .text    | code |
| Low mem  | |

### Function call stack
| Contents | High memory |
| -------- | ----------- |
| argument 2       | 24(%rbp) |
| argument 1       | 16(%rbp) |
| return           | 8(%rbp)  |
| old rbp          | <- rbp   |
| local variable 1 | -8(%rbp) |
| Low mem          | < rsp    |
For more informaton:
* [Linux x86 Assembly quick reference](https://www.cs.uaf.edu/2005/fall/cs301/support/x86/index.html)
* [X86 Assembly Notes](https://notes.shichao.io/asm/)

