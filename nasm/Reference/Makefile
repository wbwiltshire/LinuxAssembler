ASM=nasm
AFLAGS=-f elf64 -F dwarf
LD=ld
LDFLAGS=-dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e _start
SOURCES=main.asm printElapsed.asm
EXECUTABLE=reference
OBJECTS=$(SOURCES:.asm=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f $(EXECUTABLE)
	rm -f *.o
