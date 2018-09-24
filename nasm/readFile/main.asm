; -----------------------------------------------------------------------------
; A 64-bit program that displays a text file to the console
;
; On entry, rdi will contain argc and rsi will contain argv.
; -----------------------------------------------------------------------------

global  main
; -----------------------------------------------------------------------------
; We'll use the C standard library for printing a string
; -----------------------------------------------------------------------------
extern  puts

; -----------------------------------------------------------------------------
; Constants
; -----------------------------------------------------------------------------
STD_OUT    equ  1
SYS_READ   equ  0
SYS_WRITE  equ  1
SYS_OPEN   equ  2
SYS_CLOSE  equ  3
SYS_EXIT   equ  60
BUFSIZ     equ  1024
; -----------------------------------------------------------------------------
; Code Section
; -----------------------------------------------------------------------------
section .text
main:
  pop     rax 	                ; grab argument count (argc)
  cmp     rax, 0x2              ; should have 2 arguments 
  je      getParms
  
  ; Invalid number of parms
  lea     rdi, [parmErrMsg]     ; address of string to output
  call    print                 
  jmp     done
 
getParms:
  pop     rdi                   ; argv[0] executable name 
  pop     rdi                   ; argv[1] file name 
  ; open(fileName, O_RDONLY, mode)
  mov     rax, SYS_OPEN         ; syscall number for open
  xor     rsi, rsi              ; O_RDONLY = 0
  xor     rdx, rdx              ; Mode is ignored when O_CREAT isn't specified
  syscall                       ; Call the kernel (int 0x80)
  or      rax, rax              ; Check the output of open()
  jns     readFile              ; If the sign flag is set (positive) we can begin reading the file 

  ; Error on open
  lea     rdi, [openErrMsg]     ; address of string to output
  call    print                 
  jmp     done

readFile:
  mov     [fileHandle], rax     ; save file handle
next:
  ; read(int fd, void *buf, size_t count);
  mov     rdi, [fileHandle]    ; Move our file descriptor into rdi
  mov     rax, SYS_READ        ; syscall for read = 3
  lea     rsi, [buffer]        ; buffer pointer
  mov     rdx, BUFSIZ          ; The size of our buffer
  syscall
  or      rax, rax             ; Check for errors / EOF (number of bytes read)
  jz      close
  jns     printBuff            ; 
  lea     rdi, [readErrMsg]    ; If read failed, we exit.
  call    print
  jmp     done

printBuff:
  lea     rsi, [buffer]        ; address of string to output
  mov     rdx, rax             ; bytes read and to print
  call    printSys
  jmp     next                 ; print until EOF
  
close:  
  lea     rdi, [successMsg]   
  call    print
  ; close(fileDescriptor)
  mov     rax, SYS_CLOSE       ; syscall number for close
  mov     rdi, [fileHandle]
  syscall
  
done:
  ; exit(0)
  mov	  rax, SYS_EXIT        ; system call 60 is exit
  xor	  rdi, rdi             ; exit code 0
  syscall

; -----------------------------------------------------------------------------
; Print routine
; rdi - pointer to zero terminated string
; -----------------------------------------------------------------------------

print:
  push	  rcx
  call	  puts                ; print it
  pop	  rcx
  ret
; -----------------------------------------------------------------------------
; Print system routine
; rsi - pointer to string
; rdx - number of bytes to print
; -----------------------------------------------------------------------------
printSys:
  mov     rax, SYS_WRITE      ; system call 1 is write
  mov     rdi, STD_OUT        ; file handle 1 is stdout
  syscall
  ret
; -----------------------------------------------------------------------------
; Data Section
; -----------------------------------------------------------------------------
section .data	
successMsg:
  db      0x0a, 0      
parmErrMsg:
  db      "Invalid number of arguments! Usage: readfile <fileName>", 0      ; 
openErrMsg:
  db      "Error on open", 0      ; 
readErrMsg:
  db      "Error on read", 0      ;
fileHandle:
  dq      0
; -----------------------------------------------------------------------------
; Buffer Section
; -----------------------------------------------------------------------------
section .bss
buffer: 
  resb 1024       ; A 1 KB byte buffer used for read
