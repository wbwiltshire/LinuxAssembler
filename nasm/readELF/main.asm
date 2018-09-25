; ------------------------------------------------------------------------------------
; A 64-bit program that reads properties of an ELF32 (Executable Linkable Format) file
;
; ------------------------------------------------------------------------------------

global  main
; -----------------------------------------------------------------------------
; We'll use the C standard library for printing a string
;
; Use X86_64 C call convention
; parm 1 : rdi
; parm 2 : rsi
; parm 3 : rdx
;
; -----------------------------------------------------------------------------
extern  printf
extern  puts
extern  memcpy

; -----------------------------------------------------------------------------
; Constants
; -----------------------------------------------------------------------------
STD_OUT         equ  1
SYS_READ        equ  0
SYS_WRITE       equ  1
SYS_OPEN        equ  2
SYS_CLOSE       equ  3
SYS_EXIT        equ  60
BUFSZ           equ  512
ELFHDRSZ        equ  48
ELF_TYPE_NONE   equ  0
ELF_TYPE_REL    equ  1
ELF_TYPE_EXEC   equ  2
PHDR_TYPE_LOAD  equ  1
PHDR_TYPE_STACK equ  0x6474e551
; -----------------------------------------------------------------------------
; Code Section
; -----------------------------------------------------------------------------
section .text
main:
  ; On entry, stack contains argc and argv list.
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
  jns     readELFHdr            ; If the sign flag is set (positive) we can begin reading the file 

  ; Error on open
  lea     rdi, [openErrMsg]     ; address of string to output
  call    print                 
  jmp     done

readELFHdr:
  mov     [fileHandle], rax     ; save file handle
  ; read(int fd, void *buf, size_t count);
  mov     rax, SYS_READ         ; syscall for read = 3
  mov     rdi, [fileHandle]     ; Move our file descriptor into rdi
  lea     rsi, [buffer]         ; buffer pointer
  mov     rdx, BUFSZ            ; The size of our buffer
  syscall
  cmp     rax, BUFSZ            ; Check for errors or EOF (rax = number of bytes read)
  jz      moveHdr               ; Byte count matches
  lea     rdi, [readErrMsg]     ; If read failed, we exit.
  call    print
  jmp     done
moveHdr:
  add     rax, [bytesRead]
  mov     [bytesRead], rax      ; update total bytes read
  ; memcpy(void *dest, void *source, size_t count);
  lea     rdi, [elf32Hdr]       ; Copy destination
  lea     rsi, [buffer]         ; Copy source
  mov     rdx, ELFHDRSZ         ; The size of our copy
  call    memcpy
  ; NOTE: MOV operations into 32 bit sub-registers automatically zero extend to 64 bits
  mov     eax, DWORD [elfIdent]       ; it's a 32 bit value
  mov     ebx, DWORD [elf32MagNbr]    ; it's a 32 bit value
  cmp     rax, rbx
  jz      identMatched
  lea     rdi, [badMagicMsg]    ; If read failed, we exit.
  call    print
  jmp     done
identMatched:  
  lea     rdi, [goodMagicMsg]   ; 
  call    print

  ; Determine ELF Type
  movzx   rax, WORD [elfHdrType] ; it's a 16 bit value, so zero extend
  cmp     rax, ELF_TYPE_EXEC
  jnz     type1
  lea     rdi, [eLFTypeExecMsg]  
  call    print
  jmp     hdrSize
type1:
  cmp     ax, ELF_TYPE_REL
  jnz     type0
  lea     rdi, [eLFTypeRelMsg]  
  call    print
  jmp     hdrSize
type0:  
  cmp     ax, ELF_TYPE_NONE
  jnz     typeBad
  lea     rdi, [eLFTypeNoneMsg] 
  call    print
  jmp     hdrSize
typeBad:
  lea     rdi, [badELFTypeMsg]  
  call    print
  jmp     close

hdrSize:
  ;printf(char *format, char *str, value)
  ; Print ELF Header Size
  lea     rdi, [eLFHdrSzMsg]   ; format string
  movzx   rsi, WORD [elfHdrSz] ; it's a 16 bit value, so zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print Entry Point
  lea     rdi, [eLFEntryMsg]   ; format string
  ; NOTE: MOV operations into 32 bit sub-registers automatically zero extend to 64 bits
  mov     esi, DWORD [elfHdrEntry]   ; it's a 32 bit value
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print Number of ELF Program Headers 
  lea     rdi, [eLFPHNumMsg]   ;
  movzx   rsi, WORD [elfPHNum] ; it's a 16 bit value, so zero extend
  mov     r8, rsi              ; save it for loop counter below
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print ELF Program Header Offset 
  lea     rdi, [eLFPHOffMsg]   ;
  mov     esi, DWORD [elfHdrOff]     ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
    
  ; Print Program Header headers
  lea     rdi, [programHdrMsg]   
  call    print
  lea     rdi, [programHdrMsg2]  
  call    print
  
  ; Copy Program Header
  lea     rsi, [buffer]        ; Copy source
  xor     rax, rax             ; 
  mov     eax, DWORD [elfHdrOff]     ; it's a 32 bit value with auto zero extend 
  add     rsi, rax             ; Add offset for ptr to source
  call    copyPgmHdr
  movzx   rax, WORD [elfPHNum] ; it's a 16 bit value, so zero extend

pHdrLoop:
  push    rsi  
  push    rax                  ; save it for loop counter below
  ; Determine Program Header Type
  mov     eax, DWORD [elfPHdrType]   ; it's a 32 bit value with auto zero extend
  cmp     eax, PHDR_TYPE_LOAD
  jnz     pHType2
  lea     rdi, [pHdrTypeLoadMsg] 
  xor     rsi, rsi
  xor     rax, rax             ; printf has varargs
  call    printf
  jmp     printPHO
pHType2:
  cmp     eax, PHDR_TYPE_STACK
  jnz     pHTypeBad
  lea     rdi, [pHdrTypeStackMsg]   ; 
  xor     rsi, rsi
  xor     rax, rax             ; printf has varargs
  call    printf
  jmp     printPHO
pHTypeBad:
  lea     rdi, [badPHdrTypeMsg]
  xor     rsi, rsi
  xor     rax, rax             ; printf has varargs
  call    printf
  jmp     close
  
  ; Print PH Offset
printPHO:
  lea     rdi, [eLFPHOffsetMsg] ;
  xor     rsi, rsi
  mov     esi, DWORD [elfPHdrOff]    ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH Virtual Address
  lea     rdi, [eLFPHAddrMsg] ;
  mov     esi, DWORD [elfPHdrVAddr]  ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH Physical Address
  lea     rdi, [eLFPHAddrMsg] ;
  mov     esi, DWORD [elfPHdrPAddr]  ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH File Size
  lea     rdi, [eLFPHFileSzMsg] ;
  mov     esi, DWORD [elfPHdrFileSz] ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH Memory Size
  lea     rdi, [eLFPHFileSzMsg] ;
  mov     esi, DWORD [elfPHdrMemSz] ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH Flags
  lea     rdi, [eLFPHFlagsMsg] ;
  mov     esi, DWORD [elfPHdrFlags] ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  ; Print PH Alignment
  lea     rdi, [eLFPHAlignMsg] ;
  mov     esi, DWORD [elfPHdrAlign]  ; it's a 32 bit value with auto zero extend
  xor     rax, rax             ; printf has varargs
  call    printf
  
  lea     rdi, [crMsg]         ; print carriage return   
  call    print
  
  ; Print all headers
  pop     rax                  ; restore loop counter
  pop     rsi                  ; restore buffer
  movzx   rdx, WORD [elfPHEntSz]     ; The size of our header (16), so zero extend
  add     rsi, rdx             ; move to next header
  call    copyPgmHdr
  dec     rax
  jnz     pHdrLoop

next:
  ; read(int fd, void *buf, size_t count);
  ;mov     rdi, [fileHandle]    ; Move our file descriptor into rdi
  ;mov     rax, SYS_READ        ; syscall for read = 3
  ;lea     rsi, [buffer]        ; buffer pointer
  ;mov     rdx, BUFSZ           ; The size of our buffer
  ;syscall
  ;or      rax, rax             ; Check for errors or EOF (rax = number of bytes read)
  ;jz      close                ;  EOF, then done
  ;jns     printBuff            ; 
  ;lea     rdi, [readErrMsg]    ; If read failed, we exit.
  ;call    print
  ;jmp     done

printBuff:
  ;lea     rsi, [buffer]        ; address of string to output
  ;mov     rdx, rax             ; bytes read and to print
  ;call    printSys
  ;;jmp     next                 ; print until EOF
  
close:
  lea     rdi, [successMsg]   
  call    print
  ; close(fileDescriptor)
  mov     rax, SYS_CLOSE       ; syscall number for close
  mov     rdi, [fileHandle]
  syscall
  lea     rdi, [bytesReadMsg]  ; format string
  xor     esi, esi
  mov     si, [bytesRead]  
  xor     rax, rax             ; printf has varargs
  call    printf

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
; Copy Program Header routine
; rsi - pointer to source
; -----------------------------------------------------------------------------
copyPgmHdr:
  ; Save registers
  push    rsi
  push    rdi
  push    rdx     
  push    rax
  
  ; memcpy(void *dest, void *source, size_t count);
  lea     rdi, [elf32PHdr]     ; Copy destination
  movzx   rdx, WORD [elfPHEntSz]     ; The size of our copy (16), so zero extend
  call    memcpy
  
  pop     rax
  pop     rdx
  pop     rdi
  pop     rsi
  ret     
; -----------------------------------------------------------------------------
; Data Section
; -----------------------------------------------------------------------------
section .data	
successMsg:
  db      0x0a, 0      
crMsg:
  db      " ", 0      
parmErrMsg:
  db      "Invalid number of arguments! Usage: readfile <fileName>", 0      ; 
openErrMsg:
  db      "Error on open", 0      ; 
readErrMsg:
  db      "Error on read", 0      ;
badMagicMsg:
  db      "Bad ELF32 magic number", 0            ;
goodMagicMsg:
  db      0x0a, "Magic number:           ELF32", 0               ;
eLFTypeNoneMsg:
  db      "ELF Type:               None", 0                ;
eLFTypeRelMsg:
  db      "ELF Type:               REL", 0                 ;
eLFTypeExecMsg:
  db      "ELF Type:               EXEC", 0                ;
badELFTypeMsg:
  db      "ELF Type:               Unknown", 0             ; 
eLFHdrSzMsg:
  db      "ELF Header Size:        %i" , 0x0a, 0         ; 
eLFEntryMsg:
  db      "Entry point:            %#08x" , 0x0a, 0         ; 
eLFPHNumMsg:
  db      "Program header count:   %i" , 0x0a, 0         ; 
eLFPHOffMsg:
  db      "Program header offset:  %i" , 0x0a, 0         ; 
bytesReadMsg:
  db      "Total bytes read:       %i" , 0x0a, 0         ;
programHdrMsg:
  db      0x0a, "Program Headers:", 0  
programHdrMsg2:
  db      "  Type           Offset   VirtAddr   PhysAddr   FileSize MemSize  Flg Align", 0
pHdrTypeLoadMsg:
  db      "  LOAD           ", 0                 ;
pHdrTypeStackMsg:
  db      "  STACK          ", 0                ;
badPHdrTypeMsg:
  db      "  UNKNOWN        ", 0                ;
eLFPHOffsetMsg:
  db      "%#08x ", 0                
eLFPHAddrMsg:
  db      "%#010x ", 0                
eLFPHFileSzMsg:
  db      "%#08x ", 0                
eLFPHFlagsMsg:
  db      "RWE ", 0                
eLFPHAlignMsg:
  db      "%#06x ", 0                
fileHandle:
  dq      0
bytesRead:
  dq      0
elf32MagNbr:               db 0x7f, "ELF"        ; Magic number
elf32Hdr:
  elfIdent:        times 2 dq 0      	         ; ELF "magic number" (16)
  elfHdrType:              dw 0                  ; Object file type (2)
  elfHdrMachine:           dw 0                  ; Architecture (2)
  elfHdrVersion:           dd 0                  ; Object file version (4) 
  elfHdrEntry:	           dd 0                  ; Entry point virtual address (4) 
  elfHdrOff:               dd 0                  ; Program header table file offset (4) 
  elf64SHOff:              dd 0                  ; Section header table file offset  (4)
  elfFlags:                dd 0                  ; Processor-specific flags (4)
  elfHdrSz:                dw 0                  ; ELF header size in bytes (2)
  elfPHEntSz:              dw 0                  ; Program header table entry size (2) 
  elfPHNum:                dw 0                  ; Program header table entry count (2)
  elfSHEentSz:             dw 0                  ; Section header table entry size (2)
  elf64SHNum:              dw 0                  ; Section header table entry count (2)
  elfSHStrNdx:             dw 0                  ; Section header string table index (2)
  elfHdrFiller:    times 3 dd 0                  ; Filler (12)
elf32PHdr:
  elfPHdrType:             dd 0                  ; Program header Type (4)  
  elfPHdrOff:              dd 0                  ; Program header Offset (4)
  elfPHdrVAddr:            dd 0                  ; Program header Virtual Address (4) 
  elfPHdrPAddr:            dd 0                  ; Program header Physical Address (4)
  elfPHdrFileSz:           dd 0                  ; Program header file size in bytes (4)
  elfPHdrMemSz:            dd 0                  ; Program header memory size in bytes (4)
  elfPHdrFlags:            dd 0                  ; Program header Flags (4)
  elfPHdrAlign:            dd 0                  ; Program header Alignment (4)
; -----------------------------------------------------------------------------
; Buffer Section
; -----------------------------------------------------------------------------
section .bss
buffer: 
  resb 512       ; A 512 byte buffer used for read
