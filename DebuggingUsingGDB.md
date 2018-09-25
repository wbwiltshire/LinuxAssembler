Debugging GNU Assembly (GAS) using GDB
===
Some basic information on debugging assembler programs written for Linux using the GNU Assembler

### Set the number of lines to list

set listsize 20

### List a range of lines

list 100,120

### List lines in a function

list main.s:1 
list toHex.s:1, 50

### Breakpoints

break 50

break toHex.s:50

info break

delete 50

### Start debugging using a command line argument

run infile.txt
cont

### Show/change command line arguments

show args

set args infile.txt

### Execute next instruction (skip functions)

next or n

### Execute next instruction (enter functions)

step or s

### Step out of function

finish

### End debugging

q

### Display register information (must be running)

info registers
i r rax

### Set register value

set ($rax)=0x0
set ($al)=0

### Display a single register (must be running)

p/x $rax

### Print out a variables (p/f (cast)addr or x/rsf addr)

info variables

p/x (char)debugMsg

p/s (char[20])debugMsg

p/x (char[20])debugMsg

p/s (char)debugMsg

x/s &debugMsg

x/x &debugMsg

x/3c &debugMsg

x/3x &debugMsg

p/x debugMsg

p/d (int)endSecs

p/x (char)0x75626544

p/s (char)0x75626544

### Examine the call stack

where
frame

### Disassemble a assembly function (show the non-symbolic op codes and addresses)

disas _start

### Remote debugging

target remote localhost:1234 (qemu-system-i386 -boot a -fda <image> -s -S)

### For more informaton:

* [GDB Manual](https://sourceware.org/gdb/current/onlinedocs/gdb/)
* [Using GDB for Assembly Language Debugging](https://www.csee.umbc.edu/~chang/cs313.f04/gdb_help.shtml)
* [Youtube video on using GDB for Assembly code ](https://www.youtube.com/watch?v=8ymVjHCIciQ)
