CA=nasm
CFLAGS=-f elf64 -F dwarf
LD=ld
LDFLAGS=-dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e main
SOURCES=main.asm
EXECUTABLE=readELF
OBJECTS=$(SOURCES:.asm=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)
	chmod 755 $(EXECUTABLE)

%.o: %.asm
	$(CA) $(CFLAGS) $< -o $@

clean:
	rm -f $(EXECUTABLE)
	rm -f *.o
	
test:
	./$(EXECUTABLE) KRNL32.EXE
	#./$(EXECUTABLE) $(EXECUTABLE)
